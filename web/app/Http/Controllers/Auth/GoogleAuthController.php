<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use App\Models\User;

class GoogleAuthController extends Controller
{
    /**
     * POST /api/google-login
     * Body: { "id_token": "..." }
     */
    public function googleLogin(Request $request)
    {
        $idToken = $request->input('id_token');
        if (! $idToken) {
            return response()->json(['status' => 'error', 'message' => 'Missing id_token'], 400);
        }

        try {
            // Verify token with Google's tokeninfo endpoint
            $resp = Http::get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $idToken,
            ]);

            if ($resp->failed()) {
                return response()->json(['status' => 'error', 'message' => 'Invalid id_token'], 400);
            }

            $payload = $resp->json();

            // Optional: ensure audience matches your Web client id
            $expected = env('GOOGLE_CLIENT_ID');
            if ($expected && isset($payload['aud']) && $payload['aud'] !== $expected) {
                return response()->json(['status' => 'error', 'message' => 'Invalid token audience'], 400);
            }

            $email = $payload['email'] ?? null;
            if (! $email) {
                return response()->json(['status' => 'error', 'message' => 'No email in id_token'], 400);
            }

            $name = $payload['name'] ?? $email;

            // Find or create user
            $user = User::firstOrCreate(
                ['email' => $email],
                [
                    'name' => $name,
                    'password' => Hash::make(Str::random(40)),
                ]
            );

            // Create API token (Sanctum/Passport). Fallback to remember_token
            if (method_exists($user, 'createToken')) {
                $token = $user->createToken('api-token')->plainTextToken;
            } else {
                $token = bin2hex(random_bytes(40));
                $user->forceFill(['remember_token' => $token])->save();
            }

            return response()->json([
                'status' => 'success',
                'token' => $token,
                'user' => ['id' => $user->id, 'name' => $user->name, 'email' => $user->email],
            ], 200);
        } catch (\Throwable $e) {
            Log::error('Google login error: '.$e->getMessage());
            return response()->json(['status' => 'error', 'message' => 'Server error'], 500);
        }
    }
}
