<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:cda="urn:hl7-org:v3"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:jdv="http://esante.gouv.fr"
                xmlns:svs="urn:ihe:iti:svs:2008"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <xsl:processing-instruction xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="xml-stylesheet">type="text/xsl" href="rapportSchematronToHtml4.xsl"</xsl:processing-instruction>
      <xsl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl"/>
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="Rapport de conformit?? du document aux sp??cifications du mod??le ANEST-CR-ANEST du CI-SIS"
                              schemaVersion="CI-SIS_ANEST-CR-ANEST_2021.01.sch">
         <xsl:attribute name="phase">CI-SIS_ANEST-CR-ANEST_2021.01</xsl:attribute>
         <xsl:attribute name="document">
            <xsl:value-of select="document-uri(/)"/>
         </xsl:attribute>
         <xsl:attribute name="dateHeure">
            <xsl:value-of select="format-dateTime(current-dateTime(), '[D]/[M]/[Y] ?? [H]:[m]:[s] (temps UTC[Z])')"/>
         </xsl:attribute>
         <xsl:text/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_TypeAnesthesie-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_Difficulte-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_ScoreCormack-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_AbordVeineuxCentral-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_AbordVeineuxPeripherique-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_NVPO-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_ScoreASA-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_EvaluationDouleur-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_DefaillanceMaterielle-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_TypeIntubation-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_Lateralite-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_ClassificationRingMessmer-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_AccesArtere-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_HL7_ActPriority-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_TypeDM-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDV_TypeProduitSanguinLabile-CISIS</xsl:attribute>
            <svrl:text>Conformit?? d'un ??l??ment cod?? obligatoire par rapport ?? un jeu de valeurs du CI-SIS</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">S_ActesEtInterventions_ANEST-CR-ANEST</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">S_DispositifsMedicaux_ANEST-CR-ANEST</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">S_TraitementsAdministres_ANEST-CR-ANEST</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">S_CommentaireNonCodee_ANEST-CR-ANEST</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">S_ExamenPhysiqueDetaille_ANEST-CR-ANEST</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">S_PlanDeSoins_ANEST-CR-ANEST</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">S_ResultatsEvenements_ANEST-CR-ANEST</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">S_DocumentsReferences_ANEST-CR-ANEST</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">E_Acte_ActesEtInterventions_ANEST-CR-ANEST</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">JDVvariables</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Rapport de conformit?? du document aux sp??cifications du mod??le ANEST-CR-ANEST du CI-SIS</svrl:text>

   <!--PATTERN JDV_TypeAnesthesie-CISIS-->


	<!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:text/cda:reference/starts-with(@value,'#ANEST-typeAnestesie')]/cda:code"
                 priority="1000"
                 mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:text/cda:reference/starts-with(@value,'#ANEST-typeAnestesie')]/cda:code"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/code"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/code"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_TypeAnesthesie-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/code"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_TypeAnesthesie-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>

   <!--PATTERN JDV_Difficulte-CISIS-->


	<!--RULE -->
<xsl:template match="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and cda:code/@code='GEN-023']/cda:value"
                 priority="1000"
                 mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and cda:code/@code='GEN-023']/cda:value"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/observation/value"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/observation/value"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_Difficulte-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/observation/value"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_Difficulte-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>

   <!--PATTERN JDV_ScoreCormack-CISIS-->


	<!--RULE -->
<xsl:template match="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and cda:code/@code='MED-594']/cda:value"
                 priority="1000"
                 mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and cda:code/@code='MED-594']/cda:value"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/observation/value"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/observation/value"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_ScoreCormack-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/observation/value"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_ScoreCormack-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

   <!--PATTERN JDV_AbordVeineuxCentral-CISIS-->


	<!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='EPLF002']/cda:targetSiteCode"
                 priority="1000"
                 mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='EPLF002']/cda:targetSiteCode"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_AbordVeineuxCentral-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_AbordVeineuxCentral-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

   <!--PATTERN JDV_AbordVeineuxPeripherique-CISIS-->


	<!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='MED-658']/cda:targetSiteCode"
                 priority="1000"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='MED-658']/cda:targetSiteCode"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_AbordVeineuxPeripherique-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_AbordVeineuxPeripherique-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN JDV_NVPO-CISIS-->


	<!--RULE -->
<xsl:template match="cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34; and cda:value/@code=&#34;R11&#34;]//cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.1&#34; and cda:code/@code=&#34;SEV&#34;]/cda:value"
                 priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34; and cda:value/@code=&#34;R11&#34;]//cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.1&#34; and cda:code/@code=&#34;SEV&#34;]/cda:value"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_NVPO-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_NVPO-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN JDV_ScoreASA-CISIS-->


	<!--RULE -->
<xsl:template match="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and cda:code/@code='9266-8']/cda:value"
                 priority="1000"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and cda:code/@code='9266-8']/cda:value"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/observation/value"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/observation/value"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_ScoreASA-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/observation/value"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_ScoreASA-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

   <!--PATTERN JDV_EvaluationDouleur-CISIS-->


	<!--RULE -->
<xsl:template match="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.5' and cda:value/@code='R52.9']//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.1' and cda:code/@code='SEV']/cda:value"
                 priority="1000"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.5' and cda:value/@code='R52.9']//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.1' and cda:code/@code='SEV']/cda:value"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_EvaluationDouleur-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_EvaluationDouleur-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

   <!--PATTERN JDV_DefaillanceMaterielle-CISIS-->


	<!--RULE -->
<xsl:template match="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13']/cda:code[@code='Y70.8']/cda:qualifier/cda:value"
                 priority="1000"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13']/cda:code[@code='Y70.8']/cda:qualifier/cda:value"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/observation/code/qualifier/value"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/observation/code/qualifier/value"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_DefaillanceMaterielle-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/observation/code/qualifier/value"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_DefaillanceMaterielle-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>

   <!--PATTERN JDV_TypeIntubation-CISIS-->


	<!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='GELD004']/cda:targetSiteCode"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='GELD004']/cda:targetSiteCode"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_TypeIntubation-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_TypeIntubation-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

   <!--PATTERN JDV_Lateralite-CISIS-->


	<!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19']/cda:targetSiteCode/cda:qualifier/cda:value"
                 priority="1000"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19']/cda:targetSiteCode/cda:qualifier/cda:value"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode/qualifier/value"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode/qualifier/value"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_Lateralite-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode/qualifier/value"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_Lateralite-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>

   <!--PATTERN JDV_ClassificationRingMessmer-CISIS-->


	<!--RULE -->
<xsl:template match="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.5' and (cda:value/@code='T88.7' or cda:value/@code='T41.3')]//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.1']/cda:value"
                 priority="1000"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.5' and (cda:value/@code='T88.7' or cda:value/@code='T41.3')]//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.1']/cda:value"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_ClassificationRingMessmer-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_ClassificationRingMessmer-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>

   <!--PATTERN JDV_AccesArtere-CISIS-->


	<!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='MED-632']/cda:targetSiteCode"
                 priority="1000"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='MED-632']/cda:targetSiteCode"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_AccesArtere-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/targetSiteCode"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_AccesArtere-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>

   <!--PATTERN JDV_HL7_ActPriority-CISIS-->


	<!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='JQGA003']/cda:priorityCode"
                 priority="1000"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='JQGA003']/cda:priorityCode"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/priorityCode"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/priorityCode"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_HL7_ActPriority-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/priorityCode"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_HL7_ActPriority-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

   <!--PATTERN JDV_TypeDM-CISIS-->


	<!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code='MED-885']/cda:entryRelationship/cda:act/cda:code"
                 priority="1000"
                 mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code='MED-885']/cda:entryRelationship/cda:act/cda:code"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/act/code"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/act/code"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_TypeDM-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/entry/procedure/entryRelationship/act/code"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_TypeDM-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

   <!--PATTERN JDV_TypeProduitSanguinLabile-CISIS-->


	<!--RULE -->
<xsl:template match="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and cda:code/@code='933-2']/cda:value"
                 priority="1000"
                 mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and cda:code/@code='933-2']/cda:value"/>
      <xsl:variable name="att_code" select="@code"/>
      <xsl:variable name="att_codeSystem" select="@codeSystem"/>
      <xsl:variable name="att_displayName" select="@displayName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not(@nullFlavor) or 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
           [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>" ne doit pas comporter d'attribut nullFlavor.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             (@code and @codeSystem) or             (0 and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [dansJeuDeValeurs] L'??l??ment "<xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>" doit avoir ses attributs 
            @code, @codeSystem renseign??s, ou si le nullFlavor est autoris??, une valeur admise pour cet attribut, ou un xsi:type diff??rent de CD ou CE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($JDV_TypeProduitSanguinLabile-CISIS)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        
            [dansJeuDeValeurs] L'??l??ment <xsl:text/>
                  <xsl:value-of select="ClinicalDocument/component/structuredBody/component/section/component/section/entry/observation/entryRelationship/observation/value"/>
                  <xsl:text/>
            [<xsl:text/>
                  <xsl:value-of select="$att_code"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_displayName"/>
                  <xsl:text/>:<xsl:text/>
                  <xsl:value-of select="$att_codeSystem"/>
                  <xsl:text/>] 
            doit faire partie du jeu de valeurs <xsl:text/>
                  <xsl:value-of select="$JDV_TypeProduitSanguinLabile-CISIS"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>

   <!--PATTERN S_ActesEtInterventions_ANEST-CR-ANESTCI-SIS ANEST-CR-ANEST Section Actes et interventions -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">CI-SIS ANEST-CR-ANEST Section Actes et interventions </svrl:text>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11&#34;]"
                 priority="1000"
                 mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11&#34;]"/>
      <xsl:variable name="Entr??eAbordVeineuxPeriph"
                    select=".//cda:procedure[cda:templateId/@root = &#34;1.3.6.1.4.1.19376.1.5.3.1.4.19&#34; and cda:code/cda:originalText/cda:reference/@value=&#34;abord-veineux-peripherique&#34;]"/>
      <xsl:variable name="Entr??eAbordVeineuxCentral"
                    select=".//cda:procedure[cda:templateId/@root = &#34;1.3.6.1.4.1.19376.1.5.3.1.4.19&#34; and cda:code/cda:originalText/cda:reference/@value=&#34;abord-veineux-central&#34;]"/>
      <xsl:variable name="Entr??eCatheter"
                    select=".//cda:procedure[cda:templateId/@root = &#34;1.3.6.1.4.1.19376.1.5.3.1.4.19&#34; and cda:text/cda:reference/@value=&#34;#catheter&#34;]"/>
      <xsl:variable name="Entr??eVentilationAuMasque"
                    select=".//cda:procedure[cda:templateId/@root = &#34;1.3.6.1.4.1.19376.1.5.3.1.4.19&#34; and cda:text/cda:reference/@value=&#34;#ventilation-masque&#34;]"/>
      <xsl:variable name="Entr??eVentilationDispoSuprag"
                    select=".//cda:procedure[cda:templateId/@root = &#34;1.3.6.1.4.1.19376.1.5.3.1.4.19&#34; and cda:text/cda:reference/@value=&#34;#ventilation-dispositif-supraglottique&#34;]"/>
      <xsl:variable name="Entr??eIntubation"
                    select=".//cda:procedure[cda:templateId/@root = &#34;1.3.6.1.4.1.19376.1.5.3.1.4.19&#34; and cda:code/cda:originalText/cda:reference/@value=&#34;#intubation&#34;]"/>
      <xsl:variable name="Entr??eTransfusion"
                    select=".//cda:procedure[cda:templateId/@root = &#34;1.3.6.1.4.1.19376.1.5.3.1.4.19&#34; and cda:text/cda:reference/@value=&#34;#transfusion&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:title/text()=&#34;Actes r??alis??s au cours de l???intervention&#34;"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ActesEtInterventions_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Une section FR-Actes-et-interventions (1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11) doit obligatoirement contenir le title 'Actes r??alis??s au cours de l???intervention'
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:procedure[cda:templateId/@root = &#34;1.3.6.1.4.1.19376.1.5.3.1.4.19&#34; and cda:code/@code=&#34;JQGA003&#34;])&gt;=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ActesEtInterventions_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Une section FR-Actes-et-interventions (1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11) doit obligatoirement contenir une ou plusieurs entr??es de type FR-Acte (1.3.6.1.4.1.19376.1.5.3.1.4.19)  avec un ??l??ment code dont l'attribut @code='JQGA003'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:procedure[cda:templateId/@root = &#34;1.3.6.1.4.1.19376.1.5.3.1.4.19&#34; and (cda:code/@code=&#34;MED-581&#34; or cda:code/@code=&#34;MED-582&#34;             or cda:code/@code=&#34;MED-583&#34; or cda:code/@code=&#34;MED-584&#34; or cda:code/@code=&#34;MED-585&#34; or cda:code/@code=&#34;MED-586&#34; or cda:code/@code=&#34;MED-587&#34; or cda:code/@code=&#34;MED-588&#34;)])&gt;=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ActesEtInterventions_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Une section FR-Actes-et-interventions (1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11) doit obligatoirement contenir une ou plusieurs entr??es de type FR-Acte (1.3.6.1.4.1.19376.1.5.3.1.4.19) avec un ??l??ment code dont l'attribut @code 
            doit faire partie du jeu de valeurs ../jeuxDeValeurs/JDV_TypeAnesthesie-CISIS.xml.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($Entr??eAbordVeineuxPeriph) or             (count($Entr??eAbordVeineuxPeriph)=1 and $Entr??eAbordVeineuxPeriph/cda:code/@code=&#34;MED-658&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            Si elle existe, l'entr??e FR-Acte (1.3.6.1.4.1.19376.1.5.3.1.4.19) facultative de l'abord veineux p??riph??rique doit avoir un ??l??ment code avec l'attribut @code='MED-658' et une cardinalit?? [0..1].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($Entr??eAbordVeineuxCentral) or             (count($Entr??eAbordVeineuxCentral)=1 and $Entr??eAbordVeineuxCentral/cda:code/@code=&#34;EPLF002&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            Si elle existe, l'entr??e FR-Acte (1.3.6.1.4.1.19376.1.5.3.1.4.19) facultative de l'abord veineux central doit avoir un ??l??ment code avec l'attribut @code='EPLF002' et une cardinalit?? [0..1].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($Entr??eCatheter) or             (count($Entr??eCatheter)=1 and $Entr??eCatheter/cda:code/@code=&#34;MED-632&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            Si elle existe, l'entr??e FR-Acte (1.3.6.1.4.1.19376.1.5.3.1.4.19) facultative de la pose du cath??ter intra art??riel doit avoir un ??l??ment code avec l'attribut @code='MED-632' et une cardinalit?? [0..1].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(not($Entr??eVentilationAuMasque) or             (count($Entr??eVentilationAuMasque)=1 and $Entr??eVentilationAuMasque/cda:code/@code=&#34;GLLP003&#34;))             or             (not($Entr??eVentilationDispoSuprag) or             (count($Entr??eVentilationDispoSuprag)=1 and $Entr??eVentilationDispoSuprag/cda:code/@code=&#34;GDFA014&#34;))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            Si elle existe, l'entr??e FR-Acte (1.3.6.1.4.1.19376.1.5.3.1.4.19) facultative de l'acte de ventilation doit avoir un ??l??ment code avec l'attribut @code='GLLP003' ou  @code='GDFA014' et une cardinalit?? [0..1].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($Entr??eIntubation) or             (count($Entr??eIntubation)=1 and $Entr??eIntubation/cda:code/@code=&#34;GELD004&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            Si elle existe, l'entr??e FR-Acte (1.3.6.1.4.1.19376.1.5.3.1.4.19) facultative  de l'acte d'intubation doit avoir un ??l??ment code avec l'attribut @code='GELD004' et une cardinalit?? [0..1].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($Entr??eTransfusion) or             (count($Entr??eTransfusion)=1 and $Entr??eTransfusion/cda:code/@code=&#34;FELF006&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            Si elle existe, l'entr??e FR-Acte (1.3.6.1.4.1.19376.1.5.3.1.4.19) facultative  de l'acte de transfusion doit avoir un ??l??ment code avec l'attribut @code='FELF006' et une cardinalit?? [0..1].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN S_DispositifsMedicaux_ANEST-CR-ANESTCI-SIS ANEST-CR-ANEST Section Dispositifs M??dicaux -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">CI-SIS ANEST-CR-ANEST Section Dispositifs M??dicaux </svrl:text>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.2.250.1.213.1.1.2.1&#34;]" priority="1000"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.2.250.1.213.1.1.2.1&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:title/text()='Dispositifs m??dicaux'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_DispositifsMedicaux_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Une section FR-Dispositifs-medicaux (1.2.250.1.213.1.1.2.1) doit obligatoirement contenir le title 'Dispositifs m??dicaux'
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//cda:supply[cda:participant/cda:participantRole/cda:playingDevice/cda:code/@code=&#34;R51DC01&#34;]) or             (count(.//cda:supply[cda:participant/cda:participantRole/cda:playingDevice/cda:code/@code=&#34;R51DC01&#34;])&gt;=1 and .//cda:supply[cda:participant//cda:code/@code=&#34;R51DC01&#34;]/cda:entryRelationship/cda:observation/cda:code/@code=&#34;GEN-234&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_DispositifsMedicaux_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : 
            Si elle existe, l'entryRelationship de la taille du DM supraglottique doit avoir un ??l??ment code avec l'attribut @code='GEN-234'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//cda:supply[cda:participant/cda:participantRole/cda:playingDevice/cda:code/@code=&#34;R51AE&#34;]) or             (count(.//cda:supply[cda:participant/cda:participantRole/cda:playingDevice/cda:code/@code=&#34;R51AE&#34;])&gt;=1 and .//cda:supply[cda:participant//cda:code/@code=&#34;R51AE&#34;]/cda:entryRelationship/cda:observation/cda:code/@code=&#34;GEN-234&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_DispositifsMedicaux_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : 
            Si elle existe, l'entryRelationship de la taille de la sonde d'intubation doit avoir un ??l??ment code avec l'attribut @code='GEN-234'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN S_TraitementsAdministres_ANEST-CR-ANESTCI-SIS ANEST-CR-ANEST Section Traitements administr??s -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">CI-SIS ANEST-CR-ANEST Section Traitements administr??s </svrl:text>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.3.21&#34;]"
                 priority="1001"
                 mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.3.21&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(../cda:section) or ( ../cda:section and count(./cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.3.21&#34;)=1)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_TraitementsAdministres_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, une section FR-Traitements-administres (1.3.6.1.4.1.19376.1.5.3.1.3.21) doit obligatoirement contenir un seul templateId '1.3.6.1.4.1.19376.1.5.3.1.3.21'
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:title/text()=&#34;M??dicaments et gaz administr??s&#34;"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_TraitementsAdministres_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Une section FR-Traitements-administres (1.3.6.1.4.1.19376.1.5.3.1.3.21) doit obligatoirement contenir le title 'M??dicaments et gaz administr??s'
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.7&#34;]" priority="1000"
                 mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.7&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:code[@code=&#34;DRUG&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_TraitementsAdministres_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, une section FR-Traitements-administres (1.3.6.1.4.1.19376.1.5.3.1.3.21) contient[0..*] entr??es de type FR-Traitement (1.3.6.1.4.1.19376.1.5.3.1.4.7)  avec un ??l??ment code dont l'attribut @code='DRUG'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN S_CommentaireNonCodee_ANEST-CR-ANESTCI-SIS ANEST-CR-ANEST Section Commentaire non cod?? -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">CI-SIS ANEST-CR-ANEST Section Commentaire non cod?? </svrl:text>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.4.1.2.16&#34;]" priority="1000"
                 mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.4.1.2.16&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:title/text()='Observations particuli??res ou faits marquants / ??v??nements'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_CommentaireNonCodee_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, une section FR-Commentaire-ER (1.3.6.1.4.1.19376.1.4.1.2.16) doit obligatoirement contenir le title 'Observations particuli??res ou faits marquants / ??v??nements'
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

   <!--PATTERN S_ExamenPhysiqueDetaille_ANEST-CR-ANESTCI-SIS ANEST-CR-ANEST Examen physique d??taill??-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">CI-SIS ANEST-CR-ANEST Examen physique d??taill??</svrl:text>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.15&#34;]"
                 priority="1001"
                 mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.15&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:templateId[@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.29&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La section 'FR-Examen-physique-detaille-code' ne contient pas de sous-section 'Coeur'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:templateId[@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.30&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La section 'FR-Examen-physique-detaille-code' ne contient pas de sous-section'Syst??me respiratoire'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:templateId[@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.35&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La section 'FR-Examen-physique-detaille-code' ne contient pas de sous-section'Syst??me nerveux'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:templateId[@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.19&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La section 'FR-Examen-physique-detaille-code' ne contient pas de sous-section 'Syst??me oculaire'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:templateId[@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.17&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La section 'FR-Examen-physique-detaille-code' ne contient pas de sous-section 'Syst??me t??gumentaire'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:templateId[@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.33&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La section 'FR-Examen-physique-detaille-code' ne contient pas de sous-section 'Vaisseaux'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:templateId[@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.36&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La section 'FR-Examen-physique-detaille-code' ne contient pas de sous-section 'Syst??me uro-g??nital'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:templateId[@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.16&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La section 'FR-Examen-physique-detaille-code' ne contient pas de sous-section '??tat g??n??ral'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.29&#34;]"
                 priority="1000"
                 mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.9.29&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]/cda:value/@code=&#34;I46.9&#34;) &lt;=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La sous-section 'Coeur' ne contient pas l'entr??e FR-Probleme : Arr??t cardiaque.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34; and cda:value/@code=&#34;I46.9&#34;]) or              (count(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34; and cda:value/@code=&#34;I46.9&#34;])=1 and .//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34; and cda:value/@code=&#34;I46.9&#34;]//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.1.2&#34;]/cda:code/@code=&#34;11323-3&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: Si l'entr??e FR-Probleme(Arr??t cardiaque avec issue l??tale) existe, elle doit contenir l'entr??e FR-Statut-clinique-du-patient(cause du d??c??s) ayant comme code @code="11323-3".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]/cda:value/@code=&#34;T81.0&#34;)&lt;=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La sous-section 'Coeur' ne contient pas l'entr??e FR-Probleme : Saignement perop??ratoire.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]/cda:value/@code=&#34;T81.0&#34;) or             (count(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]/cda:value/@code=&#34;T81.0&#34;)=1 and .//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34; and cda:value/@code=&#34;T81.0&#34;]//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.13&#34;]/cda:code/@code=&#34;GEN-167&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: Si l'entr??e FR-Probleme(Saignement perop??ratoire) existe, elle doit contenir l'entr??e FR-Simple-Observation(quantit??) ayant comme code @code="GEN-167".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]/cda:value/@code=&#34;T80&#34;)&lt;=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: La sous-section 'Coeur' ne contient pas l'entr??e FR-Probleme : Transfusion.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]/cda:value/@code=&#34;T80&#34;) or              (count(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]/cda:value/@code=&#34;T80&#34;)=1 and .//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34; and cda:value/@code=&#34;T80&#34;]//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.13&#34;]/cda:code/@code=&#34;933-2&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: Si l'entr??e FR-Probleme(Transfusion) existe, elle doit contenir l'entr??e FR-Simple-Observation(type de produit sanguin labile) ayant comme code @code="933-2".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]/cda:value/@code=&#34;T80&#34;) or              (count(.//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]/cda:value/@code=&#34;T80&#34;)=1 and .//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34; and cda:value/@code=&#34;T80&#34;]//cda:observation[cda:templateId/@root =&#34;1.3.6.1.4.1.19376.1.5.3.1.4.13&#34;]/cda:code/@code=&#34;GEN-167&#34;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ExamenPhysiqueDetaille_ANEST-CR-ANEST.sch] Erreur de Conformit?? au volet ANEST-CR-ANEST: Si l'entr??e FR-Probleme(Transfusion) existe, elle doit contenir l'entr??e FR-Simple-Observation(quantit??) ayant comme code @code="GEN-167".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>

   <!--PATTERN S_PlanDeSoins_ANEST-CR-ANESTCI-SIS ANEST-CR-ANEST Section Plan de soins -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">CI-SIS ANEST-CR-ANEST Section Plan de soins </svrl:text>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.3.36&#34;]"
                 priority="1000"
                 mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.3.36&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:title/text()=&#34;Surveillance post-op??ratoire&#34;"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_PlanDeSoins_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, une section FR-Plan-de-soins (1.3.6.1.4.1.19376.1.5.3.1.3.36) doit obligatoirement contenir le title 'Surveillance post-op??ratoire'
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:entry/cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.20.3.1&#34; and cda:code/@code=&#34;AMBULATOIRE&#34;]) &lt;= 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_PlanDeSoins_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, une section FR-Plan-de-soins (1.3.6.1.4.1.19376.1.5.3.1.3.36) doit contenir [0..1] 
            entr??e FR-Demande-d-examen-ou-de-suivi '1.3.6.1.4.1.19376.1.5.3.1.1.20.3.1' dont l'attribut de l'??l??ment code est @code="AMBULATOIRE".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:entry/cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.20.3.1&#34; and cda:code/@code=&#34;ETABLISSEMENT&#34;]) &lt;=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_PlanDeSoins_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, une section FR-Plan-de-soins (1.3.6.1.4.1.19376.1.5.3.1.3.36) doit contenir [0..1] 
            entr??e FR-Demande-d-examen-ou-de-suivi '1.3.6.1.4.1.19376.1.5.3.1.1.20.3.1' dont l'attribut de l'??l??ment code est @code="ETABLISSEMENT".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:entry/cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.20.3.1&#34;]/cda:code[@code=&#34;AMBULATOIRE&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_PlanDeSoins_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, une section FR-Plan-de-soins (1.3.6.1.4.1.19376.1.5.3.1.3.36) doit obligatoirement 
            contenir l'??l??ment code avec un attribut @code="AMBULATOIRE".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:entry/cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.20.3.1&#34;]/cda:code[@code=&#34;ETABLISSEMENT&#34;]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_PlanDeSoins_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, une section FR-Plan-de-soins (1.3.6.1.4.1.19376.1.5.3.1.3.36) doit obligatoirement 
            contenir l'??l??ment code avec un attribut @code="ETABLISSEMENT".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:entry/cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.1.20.3.1&#34; and cda:code/@code=&#34;ETABLISSEMENT&#34;]//cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.13.2&#34;]/cda:code/@code=&#34;8310-5&#34;"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_PlanDeSoins_ANEST-CR-ANEST] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, l'entr??e FR-Demande-d-examen-ou-de-suivi : SSPI / USI / R??animation peut 
            contenir l'entr??e FR-Simple-Observation(temp??rature corporelle) qui doit avoir obligatoirement l'??l??ment code avec un attribut @code="8310-5".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>

   <!--PATTERN S_ResultatsEvenements_ANEST-CR-ANESTCI-SIS ANEST-CR-ANEST Section R??sultats d'??v??nements-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">CI-SIS ANEST-CR-ANEST Section R??sultats d'??v??nements</svrl:text>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.7.3.1.1.13.7&#34;]"
                 priority="1002"
                 mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.7.3.1.1.13.7&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:title/text()=&#34;??v??nements observ??s&#34;"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ResultatsEvenements_ANEST-CR-ANEST] Erreur de conformit?? : Si elle existe, une section FR-Resultats-evenements (1.3.6.1.4.1.19376.1.7.3.1.1.13.7) doit obligatoirement contenir le title '??v??nements observ??s'
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cda:section[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.7.3.1.1.13.7&#34;]/cda:entry/cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]"
                 priority="1001"
                 mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:section[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.7.3.1.1.13.7&#34;]/cda:entry/cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.5&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(./cda:entryRelationship[cda:act/cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.2&#34;]) &lt;= 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ResultatsEvenements_ANEST-CR-ANEST] Erreur de conformit?? : Si elle existe, une entr??e FR-Probleme doit contenir [0..1] entryRelationship FR-Commentaire-ER '1.3.6.1.4.1.19376.1.5.3.1.4.2'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(./cda:entryRelationship[cda:act/cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.1&#34;]) &lt;= 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ResultatsEvenements_ANEST-CR-ANEST] Erreur de conformit?? : Si elle existe, une entr??e FR-Probleme doit contenir [0..1] entryRelationship FR-Severite '1.3.6.1.4.1.19376.1.5.3.1.4.1'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cda:section[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.7.3.1.1.13.7&#34;]/cda:entry/cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.13&#34;]"
                 priority="1000"
                 mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:section[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.7.3.1.1.13.7&#34;]/cda:entry/cda:observation[cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.13&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(./cda:entryRelationship[cda:act/cda:templateId/@root=&#34;1.3.6.1.4.1.19376.1.5.3.1.4.2&#34;]) &lt;= 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_ResultatsEvenements_ANEST-CR-ANEST] Erreur de conformit?? : Si elle existe, une entr??e FR-Simple observation doit contenir [0..1] entryRelationship FR-Commentaire-ER '1.3.6.1.4.1.19376.1.5.3.1.4.2'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>

   <!--PATTERN S_DocumentsReferences_ANEST-CR-ANESTCI-SIS ANEST-CR-ANEST Section Documents r??f??renc??s-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">CI-SIS ANEST-CR-ANEST Section Documents r??f??renc??s</svrl:text>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.2.250.1.213.1.1.2.55&#34;]" priority="1001"
                 mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.2.250.1.213.1.1.2.55&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:title/text()=&#34;Documents r??f??renc??s&#34;"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_DocumentsReferences-CISIS] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Une section FR-Documents-references (1.2.250.1.213.1.1.2.55) doit obligatoirement
            contenir le title 'Documents r??f??renc??s'
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(./cda:entry[cda:act/cda:templateId/@root=&#34;1.2.250.1.213.1.1.3.35&#34;]) &gt;= 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_DocumentsReferences-CISIS] Erreur de conformit?? au mod??le ANEST-CR-ANEST : Si elle existe, une section FR-Documents-references (1.2.250.1.213.1.1.2.55)
            doit obligatoirement contenir [1..*] entr??e FR-References-externes(1.2.250.1.213.1.1.3.35).
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;1.2.250.1.213.1.1.3.35&#34;]" priority="1000"
                 mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[cda:templateId/@root=&#34;1.2.250.1.213.1.1.3.35&#34;]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="./cda:code/@nullFlavor=&#34;NA&#34;"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_DocumentsReferences-CISIS] Erreur de conformit?? au mod??le ANEST-CR-ANEST : l'entr??e FR-References-externes (1.2.250.1.213.1.1.3.35)
            doit obligatoirement contenir l'??l??ment code dont l'attribut @nullFlavor="NA".
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="./cda:text and count(./cda:text)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_DocumentsReferences-CISIS] Erreur de conformit?? au mod??le ANEST-CR-ANEST : l'entr??e FR-References-externes (1.2.250.1.213.1.1.3.35)
            doit obligatoirement contenir l'??l??ment text [1..1].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="./cda:reference and count(./cda:reference)&gt;=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [S_DocumentsReferences-CISIS] Erreur de conformit?? au mod??le ANEST-CR-ANEST : l'entr??e FR-References-externes (1.2.250.1.213.1.1.3.35)
            doit obligatoirement contenir un ou plusieurs ??l??ment(s) reference [1..*].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>

   <!--PATTERN E_Acte_ActesEtInterventions_ANEST-CR-ANEST-->


	<!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and (cda:code/@code='MED-581' or cda:code/@code='MED-582'         or cda:code/@code='MED-583' or cda:code/@code='MED-584' or cda:code/@code='MED-585' or cda:code/@code='MED-586' or cda:code/@code='MED-587' or cda:code/@code='MED-588' or         cda:code/@code='MED-658' or cda:code/@code='EPLF002' or cda:code/@code='MED-632'or cda:code/@code='GLLP003' or cda:code/@code='GDFA014'         or cda:code/@code='GDFA014' or cda:code/@code='MED-876' or cda:code/@code='MED-885')]"
                 priority="1001"
                 mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and (cda:code/@code='MED-581' or cda:code/@code='MED-582'         or cda:code/@code='MED-583' or cda:code/@code='MED-584' or cda:code/@code='MED-585' or cda:code/@code='MED-586' or cda:code/@code='MED-587' or cda:code/@code='MED-588' or         cda:code/@code='MED-658' or cda:code/@code='EPLF002' or cda:code/@code='MED-632'or cda:code/@code='GLLP003' or cda:code/@code='GDFA014'         or cda:code/@code='GDFA014' or cda:code/@code='MED-876' or cda:code/@code='MED-885')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13'])              or (count(.//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and not(cda:code/@code='MED-594')])=1 and             .//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13']/cda:code[@code='GEN-023'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [E_Acte_ActesEtInterventions_CRANEST] Erreur de conformit?? : L'entryRelationsip FR-Simple-Observation '1.3.6.1.4.1.19376.1.5.3.1.4.13' de la difficult?? doit avoir la cardinalit?? [0..1] et l'??l??ment code doit avoir l'attribut @code='GEN-023'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='GELD004']"
                 priority="1000"
                 mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:procedure[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.19' and cda:code/@code='GELD004']"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13']) or (count(.//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13' and not(cda:code/@code='GEN-023')])=1 and .//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13']/cda:code/@code='MED-594')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [E_Acte_ActesEtInterventions_CRANEST] Erreur de conformit?? : L'entryRelationsip FR-Simple-Observation '1.3.6.1.4.1.19376.1.5.3.1.4.13' du Score Cormack doit avoir la cardinalit?? [0..1] et l'??l??ment code doit avoir l'attribut @code='MED-594'. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13']) or (count(.//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13'] and not(cda:code/@code='MED-594'))=1 and .//cda:observation[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13']/cda:code[@code='GEN-023'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [E_Acte_ActesEtInterventions_CRANEST] Erreur de conformit?? : L'entryRelationsip FR-Simple-Observation '1.3.6.1.4.1.19376.1.5.3.1.4.13' de la difficult?? d'intubation doit avoir la cardinalit?? [0..1] et l'??l??ment code doit avoir l'attribut @code='GEN-023'.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>

   <!--PATTERN JDVvariables-->
<xsl:variable name="JDV_TypeAnesthesie-CISIS"
                 select="'../jeuxDeValeurs/JDV_TypeAnesthesie-CISIS.xml'"/>
   <xsl:variable name="JDV_Difficulte-CISIS"
                 select="'../jeuxDeValeurs/JDV_Difficulte-CISIS.xml'"/>
   <xsl:variable name="JDV_ScoreCormack-CISIS"
                 select="'../jeuxDeValeurs/JDV_ScoreCormack-CISIS.xml'"/>
   <xsl:variable name="JDV_AbordVeineuxCentral-CISIS"
                 select="'../jeuxDeValeurs/JDV_AbordVeineuxCentral-CISIS.xml'"/>
   <xsl:variable name="JDV_AbordVeineuxPeripherique-CISIS"
                 select="'../jeuxDeValeurs/JDV_AbordVeineuxPeripherique-CISIS.xml'"/>
   <xsl:variable name="JDV_TypeIntubation-CISIS"
                 select="'../jeuxDeValeurs/JDV_TypeIntubation-CISIS.xml'"/>
   <xsl:variable name="JDV_NVPO-CISIS" select="'../jeuxDeValeurs/JDV_NVPO-CISIS.xml'"/>
   <xsl:variable name="JDV_ScoreASA-CISIS" select="'../jeuxDeValeurs/JDV_ScoreASA-CISIS.xml'"/>
   <xsl:variable name="JDV_EvaluationDouleur-CISIS"
                 select="'../jeuxDeValeurs/JDV_EvaluationDouleur-CISIS.xml'"/>
   <xsl:variable name="JDV_DefaillanceMaterielle-CISIS"
                 select="'../jeuxDeValeurs/JDV_DefaillanceMaterielle-CISIS.xml'"/>
   <xsl:variable name="JDV_Lateralite-CISIS"
                 select="'../jeuxDeValeurs/JDV_LateraliteNCIT-CISIS.xml'"/>
   <xsl:variable name="JDV_ClassificationRingMessmer-CISIS"
                 select="'../jeuxDeValeurs/JDV_ClassificationRingMessmer-CISIS.xml'"/>
   <xsl:variable name="JDV_AccesArtere-CISIS"
                 select="'../jeuxDeValeurs/JDV_AccesArtere-CISIS.xml'"/>
   <xsl:variable name="JDV_HL7_ActPriority-CISIS"
                 select="'../jeuxDeValeurs/JDV_HL7_ActPriority-CISIS.xml'"/>
   <xsl:variable name="JDV_TypeDM-CISIS" select="'../jeuxDeValeurs/JDV_TypeDM-CISIS.xml'"/>
   <xsl:variable name="JDV_TypeProduitSanguinLabile-CISIS"
                 select="'../jeuxDeValeurs/JDV_TypeProduitSanguinLabile-CISIS.xml'"/>

	  <!--RULE -->
<xsl:template match="cda:ClinicalDocument" priority="1001" mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:ClinicalDocument"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:templateId[@root='1.2.250.1.213.1.1.1.40']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
                [CI-SIS_ANEST-CR-ANEST] Erreur de conformit?? au mod??le : Le templateId "1.2.250.1.213.1.1.1.40" doit ??tre pr??sent.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="./cda:code[@code='77436-4' and @codeSystem='2.16.840.1.113883.6.1']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
                [CI-SIS_ANEST-CR-ANEST] Erreur de conformit?? au mod??le : L'??l??ment "code" doit avoir les attributs @code="77436-4" et @codeSystem="2.16.840.1.113883.6.1". 
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cda:ClinicalDocument/cda:component/cda:structuredBody" priority="1000"
                 mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cda:ClinicalDocument/cda:component/cda:structuredBody"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:component/cda:section[cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11'])=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
                [CI-SIS_ANEST-CR-ANEST] Erreur de conformit?? au mod??le : La section "Actes et interventions" (1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11) doit ??tre pr??sente.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
</xsl:stylesheet>