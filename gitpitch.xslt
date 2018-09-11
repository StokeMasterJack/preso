<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xml:base=""
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text" indent="no"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="outline[@tags='section']">

        <xsl:text>&#xd;</xsl:text>
        <xsl:text>&#xd;</xsl:text>

        <xsl:text># </xsl:text> <xsl:value-of select="./@text"/> <xsl:text>&#xd;</xsl:text>

        <xsl:text>&#xd;</xsl:text>
        <xsl:for-each select="outline[@tags='slide']">
            <xsl:text>&#xd;- </xsl:text><xsl:value-of select="./@text"/>
        </xsl:for-each>
        <xsl:text>&#xd;</xsl:text>

        <xsl:text>&#xd;---&#xd;</xsl:text>

        <xsl:apply-templates/>

    </xsl:template>


    <xsl:template match="outline[@tags='slide']" >

        <xsl:text>&#xd;</xsl:text>
        <xsl:text>&#xd;</xsl:text>

        <xsl:text>### </xsl:text>
        <xsl:value-of select="./@text"/>
        <xsl:text>&#xd;</xsl:text>

        <xsl:text>&#xd;@ul</xsl:text>

        <xsl:apply-templates/>

        <xsl:text>&#xd;@ulend&#xd;</xsl:text>

        <xsl:text>&#xd;---&#xd;</xsl:text>

    </xsl:template>

    <xsl:template match="outline[@tags='slide']/outline">
        <xsl:text>&#xd;- </xsl:text><xsl:value-of select="./@text"/>

        <xsl:apply-templates/>

    </xsl:template>

    <xsl:template match="outline[@tags='slide']/outline/outline">
        <xsl:text>&#xd;    - </xsl:text><xsl:value-of select="./@text"/>

        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="text()|@*">
        <!--<xsl:value-of select="."/>-->
    </xsl:template>


</xsl:stylesheet>