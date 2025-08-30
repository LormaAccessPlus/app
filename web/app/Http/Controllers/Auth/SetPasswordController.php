<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use App\Models\User;

class SetPasswordController extends Controller
{
    // Show the set password form
    public function showSetPasswordForm(Request $request)
    {
        // show form (email may be in session or query)
        return view('auth.login', [
            'email' => $request->query('email', session('email')),
        ]);
    }

    // Handle saving the password
    public function setPassword(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email|exists:users,email',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::where('email', $data['email'])->firstOrFail();
        $user->password = Hash::make($data['password']);
        $user->save();

        Auth::login($user);

        return redirect('/home')->with('success', 'Password set and logged in.');
    }
}
