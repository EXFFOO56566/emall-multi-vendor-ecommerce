<?php

namespace App\Http\Controllers\Api\v1\User;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserAddress;
use Illuminate\Http\Request;

class UserAddressController extends Controller
{
    public function index(Request $request)
    {
        $user_id = $request->user()->id;
        return  User::find($user_id)->addresses;
    }

    public function create()
    {

    }


    public function store(Request $request)
    {
        $user_id = $request->user()->id;
        $this->validate($request,[
           'longitude'=>'required',
           'latitude'=>'required',
           'address'=>'required',
           'city'=>'required',
           'pincode'=>'required',
        ]);

        $address = new UserAddress();
        $address->longitude = $request->longitude;
        $address->latitude = $request->latitude;
        $address->address = $request->address;
        $address->address2 = $request->address2;
        $address->city = $request->city;
        $address->pincode = $request->pincode;
        $address->user_id = $user_id;

        if ($address->save()) {
            return response(['message' => 'Address added'], 200);
        }
        return response(['errors' => ['Something wrong']], 403);
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

        $userAddress = UserAddress::find($id);
        if($userAddress->delete()){
            return response(['message' => 'Address is deleted'], 200);
        }else{
            return response(['errors' => ['Something wrong']], 403);
        }


    }

}
