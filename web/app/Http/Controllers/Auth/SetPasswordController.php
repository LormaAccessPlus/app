<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class SetPasswordController extends Controller
{
    // Show the set password form
    public function showSetPasswordForm()
    {
        return view('auth.set-password');
    }

    // Handle saving the password
    public function setPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
            'password' => 'required|min:6|confirmed',
        ]);

       $user = User::where('email', $request->email)->first();
       $user->password = Hash::make($request->password);
       $user->save();

        Auth::login($user);

        return redirect('/home')->with('success', 'Password set successfully! You are now logged in.');
    }
}
