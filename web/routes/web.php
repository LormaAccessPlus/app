<?php
// require __DIR__.'/auth.php';

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Auth\GoogleAuthController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\SetPasswordController;
use App\Http\Controllers\AnnouncementsController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\AdminController;


use Illuminate\Support\Facades\Auth;

// Landing page (login)
Route::get('/', function () {
    if (Auth::check()) {
        return redirect('/home');
    }
    return view('login');
});

// Google Auth
Route::get('/auth/google/redirect', [GoogleAuthController::class, 'redirectToGoogle'])->name('auth.google.redirect');
Route::get('/auth/google/callback', [GoogleAuthController::class, 'handleGoogleCallback'])->name('auth.google.callback');

// Alias for legacy references that call route('google.login')
Route::get('/auth/google/login', function () {
    return redirect()->route('auth.google.redirect');
})->name('google.login');


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

Route::middleware('auth')->get('/classroom/courses', [GoogleAuthController::class, 'showClassroomCourses'])->name('classroom.courses');

Route::middleware(['auth', \App\Http\Middleware\EnsureSuperAdmin::class])->group(function () {
    Route::get('/admin', [AdminController::class, 'index'])->name('admin.index');
Route::get('/admin/grading-scheme', [App\Http\Controllers\GradingSchemeController::class, 'index'])
        ->name('grading.scheme');
  // save grading scheme
    Route::post('/admin/grading-scheme', [App\Http\Controllers\GradingSchemeController::class, 'store'])
        ->name('grading.scheme.save');
    });
