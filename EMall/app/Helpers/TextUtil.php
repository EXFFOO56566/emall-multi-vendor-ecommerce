<?php
namespace App\Helpers;


class TextUtil {


    public static $PLACEHOLDER_AVATAR_URL = "/placeholder_images/no_product.png";
    public static $PLACEHOLDER_PRODUCT_IMAGE_URL = "/placeholder_images/no_product.png";
    public static $PLACEHOLDER_SHOP_IMAGE_URL = "/placeholder_images/no_product.png";

    public static $DOCS_APK  = 'https://coderthemes.com/emall/downloads.html';
    public static $EMALL_APK_DOWNLOAD  = 'https://dl.dropboxusercontent.com/s/tbx3kbiyuqdbe0q/EMallApp.apk';
    public static $MANAGER_APK_DOWNLOAD  = 'https://dl.dropboxusercontent.com/s/q8j8suvw8q5xqtj/ManagerApp.apk';
    public static $DELIVERY_BOY_APK_DOWNLOAD  = 'https://dl.dropboxusercontent.com/s/g4jpm4sxa9vrl9c/DeliveryApp.apk';



    public static function getImageUrl($url,$placeholder=""): string
    {
        if($url)
            return asset('storage/'.$url);
        return asset('storage/'.$placeholder);
    }


    public static function getPhoneUrl($number): string
    {
        return "tel:".$number;
    }

    public static function getGoogleMapLocationUrl($latitude, $longitude): string
    {
        return "http://maps.google.com/maps?q=$latitude+$longitude";
    }

}

