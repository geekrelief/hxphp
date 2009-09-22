import hxphp.net.Memcache;
import haxe.unit.TestCase;

class TestMemcache extends haxe.unit.TestCase {
    var host:String;
    var port:Int;
    var port2:Int;
    var badport:Int;
    var mc:Memcache;
    var nl:String;
    var spaces:String;
    var fcallback:String->Int->Void;

    var serverVersion:String;

    public function new() {
        super();
        host = "localhost";
        port = 19789;
        port2 = 29789;
        badport = 19790;
        nl = "<br />";
        spaces = "&nbsp;&nbsp;&nbsp;&nbsp;";
        serverVersion = "1.1.32";
    }

    override public function setup() {
        mc = new Memcache();
        mc.connect(host, port);
        mc.prefix = "TestMemcache_";
    }

    override public function tearDown() {
        mc.close();
    }

    public function log(msg:String) {
        print(nl+msg);
    }

    public function test_getVersion():Void {
        var val = mc.getVersion();
        assertEquals(serverVersion, val);
        log("test_getVersion - "+val);
    }

    public function test_setGet():Void {
        assertTrue(mc.set("hello", "world", false, 10));
        var val = mc.get("hello");
        assertEquals("world", val);
        log("test_setGet - hello, "+val);
    }

    public function test_getArray():Void {
        mc.set("hello1", "world1");
        var val1 = mc.get("hello1");
        assertEquals("world1", val1);

        mc.set("hello2", "world2");
        var val2 = mc.get("hello2");
        assertEquals("world2", val2);

        var val = mc.getArray(["hello1", "hello2"]);
        assertEquals(2, val.length);
        log("test_getArray - "+val);
    }

    public function test_delete():Void {
        var val = mc.delete("hello");
        assertTrue(val);
        log("test_delete - hello, "+val);
    }

    public function test_add():Void {
        mc.delete("hello");
        var val = mc.add("hello", "world", false, 10);
        assertTrue(val);
        var val2 = mc.add("hello", "world", false, 10);
        //trace(val2);
        assertFalse(val2);
        log("test_add - hello/world, "+val+", "+val2);
    }

    public function test_decrement():Void {
        mc.delete("dec");
        var val:Dynamic = mc.decrement("dec");
        //trace(val);
        assertFalse(val);
        var val2 = mc.add("dec", 5);
        assertTrue(val2);
        var val3 = mc.decrement("dec");
        assertEquals(4, val3);
        log("test_decrement - 5, "+val3);
    }

    /*
    public function test_flush():Void {
        mc.delete("hello");
        mc.add("hello", "world", false, 10);
        var val:Bool = mc.flush();
        assertTrue(val);
        var val2 = mc.get("hello");
        assertEquals(null, val2);
        log("test_flush - "+val);
    }
    */

    public function test_getExtendedStats():Void {
        var val:Hash<Hash<Dynamic>> = mc.getExtendedStats();
        assertTrue(val != null);
        log("test_getExtendedStats - "); 
        for(i in val.keys()) {
            log(spaces+"host:port - "+i);
            
            var stats:Hash<Dynamic> = val.get(i);
            for(j in stats.keys()) {
                log(spaces+spaces+j+" - "+stats.get(j));
            }
        }
    }

    public function test_getServerStatus():Void {
        var val = mc.getServerStatus(host, port);
        assertTrue(val != 0);
        log("test_getServerStatus - "+val);
    }

    public function test_getStats():Void {
        var val = mc.getStats();
        assertTrue(val != null);
        log("test_getStats - ");
        for(j in val.keys()) {
            log(spaces+spaces+j+" - "+val.get(j));
        }
    }

    public function test_increment():Void {
        mc.delete("inc");
        var val:Dynamic = mc.increment("inc");
        assertFalse(val);
        var val2 = mc.add("inc", 5);
        assertTrue(val2);
        var val3 = mc.increment("inc");
        assertEquals(6, val3);
        log("test_increment - 5, "+val3);
    }

    public function test_pconnect():Void {
        mc.close();
        var val = mc.pconnect(host, port);
        assertTrue(val);
        log("test_pconnect - "+val);
    }

    public function test_replace():Void {
        mc.delete("hello");
        var val = mc.replace("hello", "world2");
        assertFalse(val);
        mc.add("hello", "world");
        var val2 = mc.replace("hello", "world2");
        assertTrue(val2);
        log("test_replace - hello/world2, "+val+", "+val2);
    }

    public function test_setCompressThreshold():Void {
        var val = mc.setCompressThreshold(10000, 0.2);
        assertTrue(val);
        log("test_setCompressThreshold - 10,000/0.2, "+val);
    }

    public function failureCallback_setServerParams(_host:String, _port:Int):Void {
        log(spaces+"--failureCallback_setServerParams - "+_host+" "+_port);
    }

    public function test_setServerParams():Void {
        var val = mc.setServerParams(host, port, 1, 15, true);
        assertTrue(val);
        log("test_setServerParams_good - "+val);

        var val2 = mc.setServerParams(host, badport, 1, 15, true, failureCallback_setServerParams);
        assertFalse(val2);
        log("test_setServerParams_bad - "+val+", "+val2);
    }

    public function failureCallback_addServer(_host:String, _port:Int):Void {
        log(spaces+"--failureCallback_addServer - "+_host+" "+_port);
    }

    public function test_addServer_good():Void {
        mc.close();
        mc = new Memcache();

        var val1 = mc.addServer(host, port, false, 1, 1, 15, true, failureCallback_addServer);
        assertTrue(val1);
        var val2 = mc.addServer(host, port2, false, 1, 1, 15, true, failureCallback_addServer);
        assertTrue(val2);
        
        mc.set('hello', 'world', false, 10);
        log("test_addServer_good - "+val1+", "+val2);
    }


    public function test_addServer_bad():Void {
        mc.close();
        mc = new Memcache();

        var val3 = mc.addServer(host, badport, false, 1, 1, 15, true, failureCallback_addServer);
        assertTrue(val3);
        
        mc.set('hello', 'world', false, 10);
        log("test_addServer_bad - "+val3);
    }

    public function test_lastDummy():Void {
        assertTrue(true);
        log("");
    }
}
