<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\IdLoginController;
use App\Http\Controllers\Auth\GoogleAuthController;
use App\Http\Controllers\Api\GradesController;
use App\Http\Controllers\LedgerController;

// Test route
Route::get('/test', function () {
    return response()->json(['message' => 'API is working']);
});

// ID Login
Route::post('/login', [IdLoginController::class, 'login']); // mobile ID/password login

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

Route::get('grades', [GradesController::class, 'index']);
Route::get('/ledger/{student_id}', [LedgerController::class, 'getLedger']);
`
