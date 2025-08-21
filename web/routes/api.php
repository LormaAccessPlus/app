<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GoogleController;
use App\Http\Controllers\AuthController;

Route::post('/google-login', [GoogleController::class, 'loginWithGoogle']);


Route::get('/test', function() {
    return response()->json(['message' => 'API is working']);
});

// Google login for mobile
Route::post('/google-login', [GoogleController::class, 'loginWithGoogle']);


Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function(Request $request) {
        return $request->user();
    });

});
