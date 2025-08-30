<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ChecklistController extends Controller
{
    public function forStudent(Request $request, $studid = null)
    {
        $id = $studid ?? $request->query('student_id');
        if (empty($id)) {
            return response()->json(['error' => 'student id required'], 400);
        }

        // raw select (debug)
        $rows = DB::select('SELECT Term, SchoolYear, LedgerDate, Particulars, Notes, LastModifiedBy, Debit, Credit, ORNumber, TransID FROM studentledger WHERE StudID = ?', [$id]);

        // log and dump for debugging
        Log::info('forStudent rows: ' . json_encode($rows));
        // dd($rows); // uncomment temporarily if you want to see the dump in the browser

        // force to arrays so JSON includes all keys
        $rows = array_map(function ($r) { return (array) $r; }, $rows);

        Log::info('forStudent rows (as array): ' . json_encode($rows));
        return response()->json(array_values($rows));
    }
}