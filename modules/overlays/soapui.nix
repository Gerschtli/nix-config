self: super:

let
  inherit (self) maven oraclejdk8;
  inherit (super) fetchurl stdenv writeText;
in

{
  soapui = stdenv.mkDerivation rec {
    name = "soapui-${version}";
    version = "5.3.0";

    src = fetchurl {
      url = "https://b537910400b7ceac4df0-22e92613740a7dd1247910134033c0d1.ssl.cf5.rackcdn.com/soapui/${version}/SoapUI-${version}-linux-bin.tar.gz";
      sha256 = "1x270zs9947jdpg9wziiyfh147i1ly535wg0wxfiayr6x3fwlakd";
    };

    buildInputs = [ oraclejdk8 maven ];

    installPhase = "cp -R . \$out/";

    patches = [
      (writeText "soapui-${version}.patch" ''
        --- a/bin/soapui.sh
        +++ b/bin/soapui.sh
        @@ -34,7 +34,7 @@ SOAPUI_CLASSPATH=$SOAPUI_HOME/bin/soapui-5.3.0.jar:$SOAPUI_HOME/lib/*
         export SOAPUI_CLASSPATH

         JAVA_OPTS="-Xms128m -Xmx1024m -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -Dsoapui.properties=soapui.properties -Dsoapui.home=$SOAPUI_HOME/bin -splash:SoapUI-Spashscreen.png"
        -JFXRTPATH=`java -cp $SOAPUI_CLASSPATH com.eviware.soapui.tools.JfxrtLocator`
        +JFXRTPATH=`${oraclejdk8}/bin/java -cp $SOAPUI_CLASSPATH com.eviware.soapui.tools.JfxrtLocator`
         SOAPUI_CLASSPATH=$JFXRTPATH:$SOAPUI_CLASSPATH

         if $darwin
        @@ -69,4 +69,4 @@ echo = SOAPUI_HOME = $SOAPUI_HOME
         echo =
         echo ================================

        -java $JAVA_OPTS -cp $SOAPUI_CLASSPATH com.eviware.soapui.SoapUI "$@"
        +${oraclejdk8}/bin/java $JAVA_OPTS -cp $SOAPUI_CLASSPATH com.eviware.soapui.SoapUI "$@"
      '')
    ];
  };
}
