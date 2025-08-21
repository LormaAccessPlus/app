<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Laravel\Socialite\Facades\Socialite;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class GoogleController extends Controller
{
    public function loginWithGoogle(Request $request)
    {
        try {
            // Flutter will send the "accessToken"
            $token = $request->input('token');

            // Verify with Google
            $googleUser = Socialite::driver('google')->stateless()->userFromToken($token);

            // Find or create local user
            $user = User::updateOrCreate(
                ['email' => $googleUser->getEmail()],
                [
                    'name' => $googleUser->getName(),
                    'google_id' => $googleUser->getId(),
                    'password' => bcrypt(Str::random(16)) // random password since Google login
                ]
            );

            // Generate Laravel Sanctum token (for Flutter API calls)
            $apiToken = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'status' => 'success',
                'user' => $user,
                'token' => $apiToken,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 401);
        }

        // If user exists and has NO password yet → first-time Google login
        if (!$user->password) {
            session(['email' => $user->email]);
            return redirect()->route('set-password');
        }

        // If user exists AND has a password → redirect to login form
        return redirect()->route('login')->with('email', $user->email);

    } catch (\Exception $e) {
        return redirect('/')->with('error', 'Something went wrong: ' . $e->getMessage());
    }
}

}
