<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GoogleController;
use Illuminate\Support\Facades\Auth;

// Landing page (login)
Route::get('/', function () {
    return view('login');
})->name('login');

// Google Auth
Route::get('/auth/google', [GoogleController::class, 'redirectToGoogle'])->name('google.login');
Route::get('/auth/google/callback', [GoogleController::class, 'handleGoogleCallback']);

// Home page (after login)
Route::get('/home', function () {
    return view('home');
})->middleware('auth')->name('home');

// Logout
Route::get('/logout', function () {
    Auth::logout();
    return redirect('/');
})->name('logout');
