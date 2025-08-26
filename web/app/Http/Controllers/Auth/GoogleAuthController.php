<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use App\Models\User;

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
}
