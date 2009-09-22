import haxe.unit.TestRunner;

class Index {

    static function main() {
        var r = new haxe.unit.TestRunner();
        r.add(new TestMemcache());
        r.run();
    }
}
