<?php

namespace App\Http\Controllers;

use App\Helpers\AppSetting;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Support\Str;
use Unicodeveloper\Paystack\Facades\Paystack;

class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;


    public function testView(){
        return view('test');
    }



    public function test(){

        $paystack = new \Yabacon\Paystack(AppSetting::$PAYSTACK_SECRET_KEY);
        try
        {
            $tranx = $paystack->transaction->initialize([
                'amount'=>10000,
                'email'=>AppSetting::$PAYSTACK_EMAIL_ADDRESS,         // unique to customers
                'reference'=>Str::random(16), // unique to transactions
            ]);
            return $tranx->data->access_code;
        }catch(\Yabacon\Paystack\Exception\ApiException $e){
            return null;
        }



       // return Paystack::genTranxRef();


    }



}
/*
public function index()
{

}

public function create()
{

}


public function store(Request $request)
{

}

public function show($id)
{
}


public function edit($id)
{

}


public function update(Request $request)
{

}


public function destroy($id){

}
*/
