<?php
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use App\Models\User;

class IdLoginController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'student_id' => 'required|string',
            'password'   => 'required|string',
        ]);

        $id = $request->input('student_id');
        $password = $request->input('password');

        try {
            // lookup studentdata row (table name and StudID column per your schema)
            $row = DB::table('studentdata')
                ->where('StudID', $id)
                ->first();

            if (! $row) {
                return response()->json(['status' => 'error', 'message' => 'Invalid ID or password'], 401);
            }

            // -- changed: detect actual password column --
            $stored = null;

            // prefer exact column name "SPassword"
            if (isset($row->SPassword)) {
                $stored = $row->SPassword;
            } else {
                // case-insensitive search over common password column names
                $fields = array_change_key_case((array) $row, CASE_LOWER);
                $possible = ['spassword','password','pwd','pass','pswd','studpass','stud_password','userpass','passwd','password_hash'];
                foreach ($possible as $key) {
                    if (array_key_exists($key, $fields) && $fields[$key] !== null && $fields[$key] !== '') {
                        $stored = $fields[$key];
                        break;
                    }
                }
            }

            if ($stored === null) {
                return response()->json(['status' => 'error', 'message' => 'No password set for this account'], 401);
            }

            // supports bcrypt, common hex hashes (md5/sha1/sha256) and plain-text fallback
            $ok = false;
            try {
                $s = (string) $stored;
                $sTrim = trim($s);
                // bcrypt detection ($2y$, $2a$, $2b$)
                if (preg_match('/^\$2[aby]\$/', $sTrim)) {
                    $ok = Hash::check($password, $sTrim);
                } elseif (ctype_xdigit($sTrim)) {
                    $len = strlen($sTrim);
                    if ($len === 32) { // md5
                        $ok = (md5($password) === strtolower($sTrim) || md5($password) === $sTrim);
                    } elseif ($len === 40) { // sha1
                        $ok = (sha1($password) === strtolower($sTrim) || sha1($password) === $sTrim);
                    } elseif ($len === 64) { // sha256
                        $ok = (hash('sha256', $password) === strtolower($sTrim) || hash('sha256', $password) === $sTrim);
                    } else {
                        $ok = ($password === $sTrim);
                    }
                } else {
                    // plain text or unknown format
                    $ok = ($password === $sTrim);
                }
            } catch (\Throwable $e) {
                // ensure login doesn't crash; fallback to plain comparison
                Log::warning('Password check fallback: '.$e->getMessage());
                $ok = ($password === (string) $stored);
            }
            if (! $ok) {
                return response()->json(['status' => 'error', 'message' => 'Invalid ID or password'], 401);
            }

            // create/find an app user (use email or fallback)
            $email = $row->email ?? ($id . '@lorma.edu');
            $name = $row->name ?? $row->fullname ?? ('Student ' . $id);

            $user = User::firstOrCreate(
                ['email' => $email],
                ['name' => $name, 'password' => Hash::make(Str::random(40))]
            );

            // issue API token (Sanctum) or fallback
            if (method_exists($user, 'createToken')) {
                $token = $user->createToken('api-token')->plainTextToken;
            } else {
                $token = bin2hex(random_bytes(40));
                $user->forceFill(['remember_token' => $token])->save();
            }

            // return the StudID column value
            $studentId = $row->StudID ?? null;

            // include student name fields for mobile UI
            $studentData = [
                'Prefix'     => $row->Prefix ?? null,
                'FirstName'  => $row->FirstName ?? null,
                'MiddleName' => $row->MiddleName ?? null,
                'LastName'   => $row->LastName ?? null,
                'Suffix'     => $row->Suffix ?? null,
                // add birth and nationality fields (adjust column names if different)
                'BirthDate'  => $row->BirthDate ?? $row->birthdate ?? null,
                'BirthPlace' => $row->BirthPlace ?? $row->birthplace ?? null,
                'Nationality'=> $row->Nationality ?? $row->nationality ?? null,
            ];

            return response()->json([
                'status' => 'success',
                'token'  => $token,
                'user'   => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'student_id' => $studentId,
                ],
                'student' => $studentData,
            ], 200);
        } catch (\Throwable $e) {
            Log::error('ID login error: '.$e->getMessage().' in '.$e->getFile().' on line '.$e->getLine());
            if (config('app.debug')) {
                return response()->json([
                    'status' => 'error',
                    'message' => $e->getMessage(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                ], 500);
            }
            return response()->json(['status' => 'error', 'message' => 'Server error'], 500);
        }
    }
}