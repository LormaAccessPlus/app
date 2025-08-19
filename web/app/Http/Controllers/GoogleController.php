<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Laravel\Socialite\Facades\Socialite;
use App\Models\User;

class GoogleController extends Controller
{
    // Step 1: Redirect to Google
    public function redirectToGoogle()
    {
        return Socialite::driver('google')
            ->stateless()
            ->with([
                'prompt' => 'select_account consent', // forces Google to ask for account + approval
            ])
            ->redirect();
    }

    // Step 2: Handle callback from Google
  public function handleGoogleCallback()
{
    try {
        $googleUser = Socialite::driver('google')->stateless()->user();

        // Check if user exists
        $user = User::where('email', $googleUser->getEmail())->first();

        if (!$user) {
            // First-time login: create user with null password
            $user = User::create([
                'name'      => $googleUser->getName(),
                'email'     => $googleUser->getEmail(),
                'google_id' => $googleUser->getId(),
                'password'  => null, // no password yet
            ]);

            // Redirect to set-password page
            session(['email' => $user->email]);
            return redirect()->route('set-password');
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
