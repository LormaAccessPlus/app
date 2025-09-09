@extends('components.app')

@php
    // set title used by the layout (layout currently reads $title ?? 'App')
    $title = 'Admin';
@endphp

@section('content')
    <div class="container">
        <h1 class="mb-3">Admin</h1>

        <div class="card mb-4">
            <div class="card-header">
                Grading Scheme
            </div>
            <div class="card-body">
                <p class="card-text">Define or review the grading scheme used for courses.</p>
                <a href="{{ route('grading.scheme') }}" class="btn btn-sm btn-primary">Manage Grading Scheme</a>
            </div>
        </div>

        <p>Welcome, super admin. Manage system settings here.</p>
    </div>
@endsection
