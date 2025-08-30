<?php
// require __DIR__.'/auth.php';

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Auth\GoogleAuthController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\SetPasswordController;
use App\Http\Controllers\AnnouncementsController;
use App\Http\Controllers\HomeController;


use Illuminate\Support\Facades\Auth;

// Landing page (login)
Route::get('/', function () {
    if (Auth::check()) {
        return redirect('/home');
    }
    return view('login');
});

// Google Auth
Route::get('/auth/google', [GoogleAuthController::class, 'redirectToGoogle'])->name('google.login');
Route::get('/auth/google/callback', [GoogleAuthController::class, 'handleGoogleCallback'])->name('google.callback');



Route::get('/set-password', [SetPasswordController::class, 'showSetPasswordForm'])->name('set-password');
Route::post('/set-password', [SetPasswordController::class, 'setPassword'])->name('set-password.post');

Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [LoginController::class, 'login'])->name('login.post');



Route::middleware('auth')->get('/home', [HomeController::class, 'index'])->name('home');

// show announcements list (web)
Route::middleware('auth')->group(function () {
    Route::get('/announcements', [AnnouncementsController::class, 'index'])->name('announcements.index');
    Route::get('/announcements/create', [AnnouncementsController::class, 'create'])->name('announcements.create');
    Route::post('/announcements', [AnnouncementsController::class, 'store'])->name('announcements.store');
});

// Logout
Route::get('/logout', function () {
    Auth::logout();
    return redirect('/');
})->name('logout');
