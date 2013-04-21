package hxassist;

using sys.FileSystem;
using StringTools;

using Alg;
import Alg.Fn;
import haxe.ds.Option;

using Lambda;

class FileUtils {
    public static function sanitize(file:String)
        return StringTools.replace(file, "\\", "/");

    /**
       Get the directory part of FILE
       Or "." if no match
       dir/with/file.ext.bak -> dir/with
       file.ext -> .
    **/
    public static function file_name_directory(file:String) {
        var file = sanitize(file);
        var idx = file.lastIndexOf("/");
        return if (idx == -1) ".";
        else file.substr(0, idx);
    }

    /**
       dir/with/file.ext.bak -> file.ext.bak
    **/
    public static function file_name_nondirectory(file:String) {
        var file = sanitize(file);
        var idx = file.lastIndexOf("/");
        return if (idx == -1) file;
        else file.substr(idx+1);
    }
    
    /**
       dir/with/file.ext.bak -> dir/with/file.ext
     **/
    public static function file_name_sans_ext(file:String) {
        var file = sanitize(file);
        var idx = file.lastIndexOf(".");
        return if (idx == -1) file;
        else file.substr(0, idx);
    }
        
    /**
       dir/with/file.ext.bak -> file.ext
    **/
    public static function file_base_name(file:String) {
        return file_name_sans_ext(file_name_nondirectory(file));
    }

    /**
       Finds all files upwards matching PATTERN
       Files are returned in oreder of closest to furthest
    **/
    public static function upward_match_files(dir:String, pattern:EReg):Iterable<String> {
        var dir = sanitize(dir);
        if (dir == null)
            throw 'Dir is null';
        else if (!dir.exists()) 
            throw '$dir does not exist';
        else if (!dir.isDirectory())
            throw '$dir is not a directory';
        var ct = 1000;
        var matched:Iterable<String> = [];
        while (!isRoot(dir) && ct-- > 0) {
            matched = matched.concat(dir.readDirectory()
                .filter(Fn(pattern.match(_)))
                .map(Fn('$dir/$_'))
                .list());
            dir = dir + "/..";
        }
        return matched;
    }

    /**
       Check if root directory
    **/
    public static function isRoot(dir:String) {
        return (dir.fullPath() == (dir + "/..").fullPath());
    }
}