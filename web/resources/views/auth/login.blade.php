<!DOCTYPE html>
<html>
<head>
    <title>Set Password</title>
</head>
<body>
    <h2>Set Your Password</h2>

    @if (session('success'))
        <div style="color: green">
            {{ session('success') }}
        </div>
    @endif

    @if ($errors->any())
        <div style="color: red">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form method="POST" action="{{ route('set-password.post') }}">
        @csrf

        <!-- Prefill email from session -->
        <label>Email:</label><br>
        <input type="email" name="email" value="{{ old('email', session('email')) }}" readonly><br><br>

        <label>Password:</label><br>
        <input type="password" name="password" required><br><br>

        <label>Confirm Password:</label><br>
        <input type="password" name="password_confirmation" required><br><br>

        <button type="submit">Set Password</button>
    </form>
</body>
</html>
