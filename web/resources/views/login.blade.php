<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
</head>
<body>
    <h1>Login Page</h1>

    @if(session('error'))
        <p style="color:red;">{{ session('error') }}</p>
    @endif

    <a href="{{ route('google.login') }}">
        <button>Login with Google</button>
    </a>
</body>
</html>
