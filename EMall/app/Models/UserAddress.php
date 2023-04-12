<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * @property mixed user_id
 * @property mixed pincode
 * @property mixed city
 * @property mixed address2
 * @property mixed address
 * @property mixed latitude
 * @property mixed longitude
 * @method static find($address_id)
 */
class UserAddress extends Model
{
    use HasFactory;



    public function user(){
        $this->belongsTo(User::class);

    }



}
