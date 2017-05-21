package unit.issues;

class Issue6180 extends unit.Test {
    var tmp:String;

    function test() {
        var obj:Dummy = {prop:null, a:[]};
        obj.prop = obj;
        obj.a.push(obj);
        tmp = Std.string(obj);
        t(true);
    }
}

private typedef Dummy = {
    prop:Dummy,
    a:Array<Dummy>
}