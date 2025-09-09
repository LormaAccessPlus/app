<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Str;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        $email = env('SUPER_ADMIN_EMAIL', 'admin@lorma.edu');
        $user = User::where('email', $email)->first();
        if ($user) {
            $user->is_super_admin = true;
            $user->save();
            echo "Promoted {$email}\n";
            return;
        }

        // create if missing
        User::create([
            'name' => 'Super Admin',
            'email' => $email,
            'password' => bcrypt(Str::random(16)),
            'is_super_admin' => true,
        ]);
        echo "Created and promoted {$email}\n";
    }
}