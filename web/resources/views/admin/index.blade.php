@extends('components.app')

@php
    // set title used by the layout (layout currently reads $title ?? 'App')
    $title = 'Admin';
@endphp

@section('content')
    <div class="container">
        <h1 class="mb-3">Admin</h1>
        <p>Welcome, super admin. Manage system settings here.</p>
    </div>
@endsection
