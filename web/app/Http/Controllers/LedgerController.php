<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LedgerController extends Controller
{
    public function getLedger($student_id)
    {
        $ledger = DB::table('studentledger')
            ->select('LedgerDate', 'Particulars', 'Debit', 'Credit', 'ORNumber')
            ->where('StudID', $student_id)
            ->orderBy('LedgerDate', 'asc')
            ->get();

        return response()->json($ledger);
    }
}
