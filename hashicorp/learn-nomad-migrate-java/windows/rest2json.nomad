job "rest2json" {
  datacenters = ["dc1"]

  group "proxy" {
    network {
      port "admin" {
        static = 9000
      }

      port "proxy" {
        static = 2000
      }
    }

    task "membrane" {
      template {
        destination = "local/proxy-conf/get2soap.xsl"
        data =<<EOD
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s11="http://schemas.xmlsoap.org/soap/envelope/">
  <xsl:template match="/">
    <s11:Envelope >
      <s11:Body>
        <blz:getBank xmlns:blz="http://thomas-bayer.com/blz/">
          <blz:blz><xsl:value-of select="//path/component[2]"/></blz:blz>
        </blz:getBank>
      </s11:Body>
    </s11:Envelope>
  </xsl:template>
</xsl:stylesheet>
EOD
      }

      template {
        destination = "local/proxy-conf/strip-env.xsl"
        data =<<EOD
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s11="http://schemas.xmlsoap.org/soap/envelope/">

  <xsl:template match="/">
    <xsl:apply-templates select="//s11:Body/*"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <!-- Get rid of the namespace prefixes in json. So

       ns1:getBank will be just getBank
  -->
  <xsl:template match="*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
EOD
      }

      template {
        destination = "local/proxy-conf/proxies.xml"
        data =<<EOD
<spring:beans xmlns="http://membrane-soa.org/proxies/1/"
  xmlns:spring="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
              http://membrane-soa.org/proxies/1/ http://membrane-soa.org/schemas/proxies-1.xsd">

  <router>

    <serviceProxy port="2000">
      <rest2Soap>
        <mapping regex="/bank/.*" soapAction=""
          soapURI="/axis2/services/BLZService" requestXSLT="./get2soap.xsl"
          responseXSLT="./strip-env.xsl" />
      </rest2Soap>
      <target host="thomas-bayer.com" />
    </serviceProxy>

    <serviceProxy name="Console" port="9000">
      <adminConsole />
    </serviceProxy>

  </router>

</spring:beans>
EOD
      }

      env {
        MEMBRANE_HOME="${NOMAD_TASK_DIR}/membrane-service-proxy-4.7.3"
      }

      artifact {
        source = "https://github.com/membrane/service-proxy/releases/download/v4.7.3/membrane-service-proxy-4.7.3.zip"
        destination = "local"
      }

      driver = "java"

      config {
        class = "com.predic8.membrane.core.Starter"
        class_path = "${MEMBRANE_HOME}/conf;${MEMBRANE_HOME}/starter.jar"
        args = ["-c", "local/proxy-conf/proxies.xml"]
      }
    }
  }
}