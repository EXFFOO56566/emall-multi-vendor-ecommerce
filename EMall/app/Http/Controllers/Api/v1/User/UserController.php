<?php

namespace App\Http\Controllers\Api\v1\User;

use App\Helpers\AppSetting;
use App\Http\Controllers\Controller;

class UserController extends Controller
{


    public function getAppData(){
        return response([
            'min_build_version'=> AppSetting::$EMALL_APP_MINIMUM_VERSION
        ],200);
    }



    public function getAppDataWithUser(){


        return response([
            'min_build_version'=>AppSetting::$EMALL_APP_MINIMUM_VERSION,
            'user'=>auth()->user()
        ],200);
    }


}
