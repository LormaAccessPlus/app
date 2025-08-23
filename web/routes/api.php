<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\GoogleAuthController;

// Test route
Route::get('/test', function () {
    return response()->json(['message' => 'API is working']);
});

// Flutter Google login
Route::post('google-login', [GoogleAuthController::class, 'googleLogin']);

// Protected route
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function(Request $request) {
        return response()->json([
            'id' => $request->user()->id,
            'name' => $request->user()->name,
            'email' => $request->user()->email,
        ]);
    });
});
