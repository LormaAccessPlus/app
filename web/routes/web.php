<?php
// require __DIR__.'/auth.php';

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GoogleController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\SetPasswordController;


use Illuminate\Support\Facades\Auth;

// Landing page (login)
Route::get('/', function () {
    return view('login');
})->name('login');

// Google Auth
Route::get('/auth/google', [GoogleController::class, 'redirectToGoogle'])->name('google.login');
Route::get('/auth/google/callback', [GoogleController::class, 'handleGoogleCallback'])->name('google.callback');



Route::get('/set-password', [SetPasswordController::class, 'showSetPasswordForm'])->name('set-password');
Route::post('/set-password', [SetPasswordController::class, 'setPassword'])->name('set-password.post');

Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [LoginController::class, 'login'])->name('login.post');



Route::get('/home', function() {
    return view('home');
})->middleware('auth');
// Logout
Route::get('/logout', function () {
    Auth::logout();
    return redirect('/');
})->name('logout');
