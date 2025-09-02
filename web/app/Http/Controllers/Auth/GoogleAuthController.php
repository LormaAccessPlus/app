<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use App\Models\User;
use Carbon\Carbon;

class GoogleAuthController extends Controller
{
    /**
     * POST /api/google-login
     * Accepts either:
     *  - server_auth_code (recommended): exchanges for tokens server-side
     *  - id_token: verification-only flow
     *
     * Returns: { status, token, user: { id, name, email, student_id }, tokens? }
     */
    public function googleLogin(Request $request)
    {
        $serverCode = $request->input('server_auth_code');
        $idToken = $request->input('id_token');

        // If client provided server_auth_code, exchange it for tokens (web client credentials)
        $tokens = null;
        if ($serverCode) {
            $exchange = Http::asForm()->post('https://oauth2.googleapis.com/token', [
                'code' => $serverCode,
                'client_id' => env('GOOGLE_CLIENT_ID'),
                'client_secret' => env('GOOGLE_CLIENT_SECRET'),
                'redirect_uri' => 'postmessage',
                'grant_type' => 'authorization_code',
            ]);

            if ($exchange->failed()) {
                Log::error('Google token exchange failed: '.$exchange->body());
                return response()->json(['status' => 'error', 'message' => 'Token exchange failed'], 400);
            }

            $tokens = $exchange->json();
            $idToken = $tokens['id_token'] ?? $idToken;
        }

        if (! $idToken) {
            return response()->json(['status' => 'error', 'message' => 'Missing id_token or server_auth_code'], 400);
        }

        try {
            // Verify id_token with Google
            $verify = Http::get('https://oauth2.googleapis.com/tokeninfo', ['id_token' => $idToken]);
            if ($verify->failed()) {
                return response()->json(['status' => 'error', 'message' => 'Invalid id_token'], 400);
            }

            $payload = $verify->json();

            // Enforce hosted domain if set in .env
            $expectedDomain = env('GOOGLE_HOSTED_DOMAIN');
            if ($expectedDomain) {
                if (empty($payload['hd']) || $payload['hd'] !== $expectedDomain) {
                    return response()->json(['status' => 'error', 'message' => 'Not allowed domain'], 403);
                }
            }

            // Optional: ensure audience matches if you want strict aud check
            $expectedAud = env('GOOGLE_CLIENT_ID');
            if ($expectedAud && isset($payload['aud']) && $payload['aud'] !== $expectedAud) {
                // If you use multiple client IDs, adjust logic accordingly
                // For now, allow if aud not set or differs (remove this block if it blocks mobile)
            }

            $email = $payload['email'] ?? null;
            if (! $email) {
                return response()->json(['status' => 'error', 'message' => 'No email in token'], 400);
            }

            $name = $payload['name'] ?? $email;

            // Find or create application user
            $user = User::firstOrCreate(
                ['email' => $email],
                [
                    'name' => $name,
                    'password' => Hash::make(Str::random(40)),
                ]
            );

            // Store refresh_token if present (requires google_refresh_token column)
            if (!empty($tokens['refresh_token'])) {
                try {
                    $user->forceFill(['google_refresh_token' => $tokens['refresh_token']])->save();
                } catch (\Throwable $e) {
                    Log::warning('Failed to save google_refresh_token for '.$email.' : '.$e->getMessage());
                }
            }

            // Lookup Studentdata table for the student ID (adjust column name if yours differs)
            $studentId = null;
            try {
                $row = DB::table('Studentdata')->where('email', $email)->first();
                if ($row) {
                    // try common column names; update to your exact column if needed
                    $studentId = $row->student_id ?? $row->id_number ?? $row->studentnumber ?? $row->idno ?? $row->id ?? null;
                }
            } catch (\Throwable $e) {
                Log::warning('Studentdata lookup failed for '.$email.': '.$e->getMessage());
            }

            // Create app API token (Sanctum or fallback)
            if (method_exists($user, 'createToken')) {
                $apiToken = $user->createToken('api-token')->plainTextToken;
            } else {
                $apiToken = bin2hex(random_bytes(40));
                $user->forceFill(['remember_token' => $apiToken])->save();
            }

            $response = [
                'status' => 'success',
                'token' => $apiToken,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'student_id' => $studentId,
                ],
            ];

            // Debug tokens for development only
            if (env('APP_DEBUG') && $tokens) {
                $response['tokens'] = $tokens;
            }

            return response()->json($response, 200);
        } catch (\Throwable $e) {
            Log::error('Google login error: '.$e->getMessage());
            return response()->json(['status' => 'error', 'message' => 'Server error'], 500);
        }
    }

    /**
     * Redirect the user to Google for authentication.
     */
    public function redirectToGoogle()
    {
        return Socialite::driver('google')
            ->scopes([
                'openid','profile','email',
                'https://www.googleapis.com/auth/classroom.courses.readonly',
                'https://www.googleapis.com/auth/classroom.rosters.readonly'
            ])
            ->with(['access_type' => 'offline', 'prompt' => 'consent'])
            ->redirect();
    }

    /**
     * Handle callback from Google.
     */
    public function handleGoogleCallback()
    {
        // For web flows prefer stateful Socialite (remove ->stateless() unless necessary)
        $socialUser = Socialite::driver('google')->user();

        $user = User::firstOrCreate(
            ['email' => $socialUser->getEmail()],
            [
                'name' => $socialUser->getName() ?? $socialUser->getEmail(),
                'password' => bcrypt(Str::random(40)),
            ]
        );

        // Save refresh token if present
        if (! empty($socialUser->refreshToken)) {
            $user->forceFill(['google_refresh_token' => $socialUser->refreshToken])->save();
        }

        // Log the user into the session
        Auth::login($user, true);

        // Redirect to home instead of classroom.courses
        return redirect()->route('home');
    }

    /**
     * Show Classroom courses (subjects) in a Blade view.
     */
    public function showClassroomCourses(Request $request)
    {
        $user = Auth::user();
        if (! $user) {
            return redirect()->route('login');
        }

        $refreshToken = $user->google_refresh_token ?? null;
        if (! $refreshToken) {
            return view('classroom.courses', ['subjectsByYear' => [], 'error' => 'No Google refresh token stored.']);
        }

        $tokenResp = Http::asForm()->post('https://oauth2.googleapis.com/token', [
            'client_id' => env('GOOGLE_CLIENT_ID'),
            'client_secret' => env('GOOGLE_CLIENT_SECRET'),
            'refresh_token' => $refreshToken,
            'grant_type' => 'refresh_token',
        ]);

        if ($tokenResp->failed()) {
            Log::error('Failed to refresh Google token for user '.$user->email.' : '.$tokenResp->body());
            return view('classroom.courses', ['subjectsByYear' => [], 'error' => 'Failed to obtain access token.']);
        }

        $accessToken = $tokenResp->json('access_token');
        if (! $accessToken) {
            return view('classroom.courses', ['subjectsByYear' => [], 'error' => 'No access token returned.']);
        }

        $coursesResp = Http::withToken($accessToken)
            ->get('https://classroom.googleapis.com/v1/courses', ['pageSize' => 200]);

        if ($coursesResp->failed()) {
            Log::error('Google Classroom API error for '.$user->email.' : '.$coursesResp->body());
            return view('classroom.courses', ['subjectsByYear' => [], 'error' => 'Failed to fetch courses.']);
        }

        $courses = $coursesResp->json('courses', []);

        $subjects = array_map(function ($c) {
            // text used to heuristically detect semester
            $text = strtolower(trim(($c['section'] ?? '') . ' ' . ($c['name'] ?? '') . ' ' . ($c['descriptionHeading'] ?? $c['description'] ?? '')));

            // include creationTime if available
            $creation = $c['creationTime'] ?? null;
            $year = null;
            if (!empty($creation)) {
                try { $year = Carbon::parse($creation)->year; } catch (\Throwable $e) { $year = null; }
            }
            if (!$year && preg_match('/\b(20\d{2}|19\d{2})\b/', $text, $ym)) {
                $year = $ym[1];
            }
            $year = $year ?: 'Unknown';

            // detect semester heuristics
            $semester = 'Unknown';

            // prefer explicit "summer" mention
            if (preg_match('/\b(summer|summer\s*term|mid\s*term)\b/i', $text)) {
                $semester = 'Summer';
            } elseif (preg_match('/\b(term\s*1|1st|first|sem(?:ester)?\s*1|sem1|s1|^1\b)\b/i', $text)) {
                $semester = 'First';
            } elseif (preg_match('/\b(term\s*2|2nd|second|sem(?:ester)?\s*2|sem2|s2|^2\b)\b/i', $text)) {
                $semester = 'Second';
            } elseif ($creation) {
                try {
                    $m = Carbon::parse($creation)->month;
                    // heuristic:
                    // Jun(6)-Dec(12) => First
                    // Apr(4)-May(5) => Summer
                    // Jan(1)-Mar(3) => Second
                    if ($m >= 6 && $m <= 12) {
                        $semester = 'First';
                    } elseif ($m >= 4 && $m <= 5) {
                        $semester = 'Summer';
                    } else {
                        $semester = 'Second';
                    }
                } catch (\Throwable $e) {
                    $semester = 'Unknown';
                }
            }

            return [
                'id' => $c['id'] ?? null,
                'name' => $c['name'] ?? null,
                'section' => $c['section'] ?? null,
                'room' => $c['room'] ?? null,
                'description' => $c['descriptionHeading'] ?? $c['description'] ?? null,
                'link' => $c['alternateLink'] ?? null,
                'year' => (string) $year,
                'semester' => $semester,
            ];
        }, $courses);

        // group by year then semester
        $subjectsByYear = [];
        foreach ($subjects as $s) {
            $y = $s['year'] ?? 'Unknown';
            $sem = $s['semester'] ?? 'Unknown';
            if (! isset($subjectsByYear[$y])) {
                $subjectsByYear[$y] = ['First' => [], 'Summer' => [], 'Second' => [], 'Unknown' => []];
            }
            $subjectsByYear[$y][$sem][] = $s;
        }

        // sort years descending, Unknown last
        uksort($subjectsByYear, function ($a, $b) {
            if ($a === 'Unknown') return 1;
            if ($b === 'Unknown') return -1;
            return intval($b) <=> intval($a);
        });

        return view('classroom.courses', ['subjectsByYear' => $subjectsByYear, 'error' => null]);
    }

    /**
     * GET /api/classroom/courses
     * Query param: user_id (optional if authenticated). Returns JSON list of courses
     * with optional parsed 'days', 'start_time', 'end_time'.
     */
    public function getClassroomCoursesApi(Request $request)
    {
        // determine user: prefer authenticated, else accept user_id param for testing/mobile
        $user = Auth::user();
        if (! $user) {
            $userId = $request->query('user_id');
            if (! $userId) {
                return response()->json(['message' => 'user_id required when unauthenticated'], 400);
            }
            $user = User::find($userId);
            if (! $user) {
                return response()->json(['message' => 'user not found'], 404);
            }
        }

        $refreshToken = $user->google_refresh_token ?? null;
        if (! $refreshToken) {
            return response()->json(['message' => 'No Google refresh token stored for user'], 400);
        }

        // refresh access token
        $tokenResp = Http::asForm()->post('https://oauth2.googleapis.com/token', [
            'client_id' => env('GOOGLE_CLIENT_ID'),
            'client_secret' => env('GOOGLE_CLIENT_SECRET'),
            'refresh_token' => $refreshToken,
            'grant_type' => 'refresh_token',
        ]);

        if ($tokenResp->failed()) {
            Log::error('Failed to refresh Google token for user '.$user->email.' : '.$tokenResp->body());
            return response()->json(['message' => 'Failed to obtain access token'], 500);
        }

        $accessToken = $tokenResp->json('access_token');
        if (! $accessToken) {
            return response()->json(['message' => 'No access token returned'], 500);
        }

        // fetch courses
        $coursesResp = Http::withToken($accessToken)
            ->get('https://classroom.googleapis.com/v1/courses', ['pageSize' => 500]);

        if ($coursesResp->failed()) {
            Log::error('Google Classroom API error for '.$user->email.' : '.$coursesResp->body());
            return response()->json(['message' => 'Failed to fetch courses'], 500);
        }

        $courses = $coursesResp->json('courses', []);

        // parse days/times with simple regex (look in section/name/description)
        $parsed = array_map(function ($c) {
            $text = trim(
                ($c['section'] ?? '') . ' '
                . ($c['name'] ?? '') . ' '
                . ($c['descriptionHeading'] ?? $c['description'] ?? '')
            );

            // find weekdays (Mon/Tue/Wed/Thu/Fri/Sat/Sun or full)
            preg_match_all('/\b(Mon|Monday|Tue|Tues|Tuesday|Wed|Wednesday|Thu|Thur|Thursday|Fri|Friday|Sat|Saturday|Sun|Sunday)\b/i', $text, $dayMatches);
            $days = [];
            if (!empty($dayMatches[0])) {
                foreach ($dayMatches[0] as $dm) {
                    $d = strtolower($dm);
                    if (str_starts_with($d, 'mon')) $days[] = 'Mon';
                    elseif (str_starts_with($d, 'tue')) $days[] = 'Tue';
                    elseif (str_starts_with($d, 'wed')) $days[] = 'Wed';
                    elseif (str_starts_with($d, 'thu') || str_starts_with($d, 'thur')) $days[] = 'Thu';
                    elseif (str_starts_with($d, 'fri')) $days[] = 'Fri';
                    elseif (str_starts_with($d, 'sat')) $days[] = 'Sat';
                    elseif (str_starts_with($d, 'sun')) $days[] = 'Sun';
                }
                $days = array_values(array_unique($days));
            }

            // find time range like 08:00-10:00 or 8:00 - 10:00 or 08:00 AM - 10:00 AM (simple)
            $start = null; $end = null;
            if (preg_match('/\b(\d{1,2}:\d{2})\s*[-–]\s*(\d{1,2}:\d{2})\b/', $text, $timeM)) {
                $start = $timeM[1];
                $end = $timeM[2];
            }

            // fallback: derive year from creationTime or name
            $year = null;
            if (!empty($c['creationTime'])) {
                try { $year = Carbon::parse($c['creationTime'])->year; } catch (\Throwable $e) {}
            }
            if (!$year && preg_match('/\b(20\d{2}|19\d{2})\b/', $text, $ym)) {
                $year = $ym[1];
            }
            $year = $year ?: 'Unknown';

            return [
                'id' => $c['id'] ?? null,
                'name' => $c['name'] ?? null,
                'section' => $c['section'] ?? null,
                'room' => $c['room'] ?? null,
                'description' => $c['descriptionHeading'] ?? $c['description'] ?? null,
                'link' => $c['alternateLink'] ?? null,
                'days' => $days, // array of short day codes (Mon/Tue/...)
                'start_time' => $start,
                'end_time' => $end,
                'year' => (string)$year,
            ];
        }, $courses);

        return response()->json(['courses' => $parsed], 200);
    }
}
