<!DOCTYPE html>
<html>
<head>
    <title>Home</title>
</head>
<body>
    <h1>Welcome, {{ Auth::user()->name }}</h1>
    <p>Email: {{ Auth::user()->email }}</p>

    <a href="{{ route('logout') }}">
        <button>Logout</button>
    </a>
</body>
</html>
