<?php
?>

<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
</head>
<body>
    <h2>Sign in with Lorma</h2>

    @if(session('error'))
        <div style="color: red">{{ session('error') }}</div>
    @endif
    @if(session('success'))
        <div style="color: green">{{ session('success') }}</div>
    @endif

    <a href="{{ route('google.login') }}">
        <button type="button">Sign in with Google (lorma.edu)</button>
    </a>
</body>
</html>
