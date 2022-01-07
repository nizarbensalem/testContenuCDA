<?xml version="1.0" encoding="UTF-8"?><!-- CI-SIS_VSM_1.4
        
        Schématron du Volet de Synthèse Médicale (VSM 2013)
        Auteur : ANS 
        Historique :
        27/09/2019 Création 
        09/06/2020 Suppression du contrôle de la section Traitement au long court qui est fait dans le schématron S_traitementAuLongCours_ASIP.sch
--><schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:cda="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" defaultPhase="CI-SIS_VSM_1.4" queryBinding="xslt2" schemaVersion="CI-SIS_VSM_1.4.sch">

        <title>Vérification de conformité du document aux spécifications du modèle VSM_1.4</title>
        <ns prefix="cda" uri="urn:hl7-org:v3"/>
        <ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
        <ns prefix="jdv" uri="http://esante.gouv.fr"/>
        <ns prefix="svs" uri="urn:ihe:iti:svs:2008"/>

        <!--  Abstract patterns  -->
        <?DSDL_INCLUDE_START abstract/dansJeuDeValeurs.sch?><pattern xmlns:svs="urn:ihe:iti:svs:2008" id="dansJeuDeValeurs" abstract="true">
    <p>Conformité d'un élément codé obligatoire par rapport à un jeu de valeurs du CI-SIS</p>
    <rule context="$xpath_elt">
        <let name="att_code" value="@code"/>
        <let name="att_codeSystem" value="@codeSystem"/>
        <let name="att_displayName" value="@displayName"/>
        
        <assert test="(not(@nullFlavor) or $nullFlavor)">
           [dansJeuDeValeurs] L'élément "<value-of select="$vue_elt"/>" ne doit pas comporter d'attribut nullFlavor.
        </assert> 
        
        <assert test="(             (@code and @codeSystem) or             ($nullFlavor and              (@nullFlavor='UNK' or              @nullFlavor='NA' or              @nullFlavor='NASK' or              @nullFlavor='ASKU' or              @nullFlavor='NI' or              @nullFlavor='NAV' or              @nullFlavor='MSK' or              @nullFlavor='OTH')) or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE'))             )">
            [dansJeuDeValeurs] L'élément "<value-of select="$vue_elt"/>" doit avoir ses attributs 
            @code, @codeSystem renseignés, ou si le nullFlavor est autorisé, une valeur admise pour cet attribut, ou un xsi:type différent de CD ou CE.
        </assert>
        
        <assert test="(             @nullFlavor or             (@xsi:type and not(@xsi:type = 'CD') and not(@xsi:type = 'CE')) or              (document($path_jdv)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem])             )">
        <!--  débrayage du contrôle sur le displayName qui risque de générer un trop grand nombre d'assert-failed en raison d'une différence 
              non significative de libellé (pb de casse d'un caractère, un espace en trop, un caractère "'" mal codé ...
        <assert test="@nullFlavor or 
                     (document($path_jdv)//svs:Concept[@code=$att_code and @codeSystem=$att_codeSystem and @displayName=$att_displayName])">
        -->
            [dansJeuDeValeurs] L'élément <value-of select="$vue_elt"/>
            [<value-of select="$att_code"/>:<value-of select="$att_displayName"/>:<value-of select="$att_codeSystem"/>] 
            doit faire partie du jeu de valeurs <value-of select="$path_jdv"/>.
        </assert>
    </rule>
</pattern><?DSDL_INCLUDE_END abstract/dansJeuDeValeurs.sch?>
        <?DSDL_INCLUDE_START abstract/IVL_TS.sch?><pattern id="IVL_TS" abstract="true">
    <p>
        Vérification de la conformité au CI-SIS d'un élément de type IVL_TS ou TS du standard CDAr2 :
        L'élément doit porter soit un attribut "value" soit un intervalle éventuellement semi-borné de sous-éléments "low", "high". 
        Alternativement, si l'attribut nullFlavor est autorisé, il doit porter l'une des valeurs admises par le CI-SIS. 
    </p>
    <rule context="$elt">
        <let name="L" value="string-length(@value)"/>
        <let name="mm" value="number(substring(@value,5,2))"/>
        <let name="dd" value="number(substring(@value,7,2))"/>            
        <let name="hh" value="number(substring(@value,9,2))"/>
        <let name="lzp" value="string-length(substring-after(@value,'+'))"/> 
        <let name="lzm" value="string-length(substring-after(@value,'-'))"/>
        <let name="lDH1" value="string-length(substring-before(@value,'+'))"/>
        <let name="lDH2" value="string-length(substring-before(@value,'-'))"/>
        <assert test="(             ($L = 0) or             ($L = 4) or              ($L = 6 and $mm &lt;= 12) or              ($L = 8 and $mm &lt;= 12 and $dd &lt;= 31) or              ($L &gt; 14 and $mm &lt;= 12 and $dd &lt;= 31 and $hh &lt; 24 and ($lzp = 4 or $lzm = 4) and $lDH1 &lt;= 14 and $lDH2 &lt;= 14)             )">
            [IVL_TS.sch] Erreur de conformité CI-SIS : <value-of select="$vue_elt"/>/@value = "<value-of select="@value"/>"  contient  
            une date et heure invalide, différente de aaaa ou aaaamm ou aaaammjj ou aaaammjjhh[mm[ss]][+/-]zzzz 
            en temps local du producteur.
        </assert>
        <assert test="(@* and not(*)) or (not(@*) and *)">
            [IVL_TS.sch] Erreur de conformité CI-SIS : <value-of select="$vue_elt"/> doit contenir soit un attribut soit des éléments fils.
        </assert>
        <assert test="(             (name(@*) = 'nullFlavor' and $nullFlavor and             (@* = 'UNK' or @* = 'NASK' or @* = 'ASKU' or @* = 'NAV' or @* = 'MSK')) or             (name(@*) != 'nullFlavor')              )">
            [IVL_TS.sch] Erreur de conformité CI-SIS : <value-of select="$vue_elt"/> contient un 'nullFlavor' non autorisé ou porteur d'une valeur non admise.
        </assert>  
        
        <!-- On test que la valeur high soit plus élevée que la valeur low -->
        <assert test="not(cda:low and cda:high) or cda:high/@value &gt; cda:low/@value or cda:high/@nullFlavor">
            [IVL_TS.sch] Erreur de conformité CDA : L'élément de temps 'high' doit être supérieur à l'élément de temps 'low'
        </assert>
        
    </rule> 

    <rule context="$elt/cda:low">
        <let name="L" value="string-length(@value)"/>
        <let name="mm" value="number(substring(@value,5,2))"/>
        <let name="dd" value="number(substring(@value,7,2))"/>            
        <let name="hh" value="number(substring(@value,9,2))"/>
        <let name="lzp" value="string-length(substring-after(@value,'+'))"/> 
        <let name="lzm" value="string-length(substring-after(@value,'-'))"/>
        <let name="lDH1" value="string-length(substring-before(@value,'+'))"/>
        <let name="lDH2" value="string-length(substring-before(@value,'-'))"/>
        <assert test="(             ($L = 0) or             ($L = 4) or              ($L = 6 and $mm &lt;= 12) or              ($L = 8 and $mm &lt;= 12 and $dd &lt;= 31) or              ($L &gt; 14 and $mm &lt;= 12 and $dd &lt;= 31 and $hh &lt; 24 and ($lzp = 4 or $lzm = 4) and $lDH1 &lt;= 14 and $lDH2 &lt;= 14)             )">
            [IVL_TS.sch] Erreur de conformité CI-SIS : <value-of select="$vue_elt"/>/low/@value = "<value-of select="@value"/>"  contient  
            une date et heure invalide, différente de aaaa ou aaaamm ou aaaammjj ou aaaammjjhh[mm[ss]][+/-]zzzz 
            en temps local du producteur.
        </assert>
    </rule>
    
    <rule context="$elt/cda:high">
        <let name="L" value="string-length(@value)"/>
        <let name="mm" value="number(substring(@value,5,2))"/>
        <let name="dd" value="number(substring(@value,7,2))"/>            
        <let name="hh" value="number(substring(@value,9,2))"/>
        <let name="lzp" value="string-length(substring-after(@value,'+'))"/> 
        <let name="lzm" value="string-length(substring-after(@value,'-'))"/>
        <let name="lDH1" value="string-length(substring-before(@value,'+'))"/>
        <let name="lDH2" value="string-length(substring-before(@value,'-'))"/>
        <assert test="(             ($L = 0) or             ($L = 4) or              ($L = 6 and $mm &lt;= 12) or              ($L = 8 and $mm &lt;= 12 and $dd &lt;= 31) or              ($L &gt; 14 and $mm &lt;= 12 and $dd &lt;= 31 and $hh &lt; 24 and ($lzp = 4 or $lzm = 4) and $lDH1 &lt;= 14 and $lDH2 &lt;= 14)             )">
            [IVL_TS.sch] Erreur de conformité CI-SIS : <value-of select="$vue_elt"/>/high/@value = "<value-of select="@value"/>"  contient  
            une date et heure invalide, différente de aaaa ou aaaamm ou aaaammjj ou aaaammjjhh[mm[ss]][+/-]zzzz 
            en temps local du producteur.
        </assert>
     </rule>       

</pattern><?DSDL_INCLUDE_END abstract/IVL_TS.sch?>

        <phase id="CI-SIS_VSM_1.4">
                <active pattern="variables"/>
                <p>Vérification complète de la conformité au CI-SIS</p>
        </phase>
        
        <pattern id="variables">

                <rule context="cda:ClinicalDocument">
                        <!-- Verifier le templateId du modèle VSM 2013 -->
                        <assert test="cda:templateId[@root='1.2.250.1.213.1.1.1.13']"> 
                                [VSM] Le templateId "Conformité au VSM" (1.2.250.1.213.1.1.1.13) doit être présent.
                        </assert>
                        <!-- Verifier le code du modèle VSM 2013 -->
                       <assert test="cda:code[@code='SYNTH' and @codeSystem='1.2.250.1.213.1.1.4.12']"> 
                                [VSM] L'élément code doit avoir @code ="SYNTH" et @codeSystem = "1.2.250.1.213.1.1.4.12"/&gt;. 
                        </assert>
                </rule>
                
                <rule context="cda:ClinicalDocument/cda:component/cda:structuredBody">
                        <!-- Vérifier la présence de la section "Pathologies, antécédents, allergies et facteurs de risque"-->
                        <assert test="cda:component/cda:section/cda:templateId[@root='1.2.250.1.213.1.1.2.29']"> 
                                [VSM] Erreur de conformité au volet VSM : La section "Pathologies, antécédents, allergies et facteurs de risque" (1.2.250.1.213.1.1.2.29) doit être présente.
                        </assert>
                        
                        <!-- Verifier la présence de la section "Résultats"-->
                        <assert test="cda:component/cda:section/cda:templateId[@root='1.3.6.1.4.1.19376.1.5.3.1.3.27']"> 
                                [VSM] Erreur de conformité au volet VSM : La section "Résultats" (1.3.6.1.4.1.19376.1.5.3.1.3.27) doit être présente.
                        </assert>
                        
                        <!--  Verifier la présence de la section "Traitement au long cours"-->
                        <assert test="cda:component/cda:section/cda:templateId[@root='1.2.250.1.213.1.1.2.32']"> 
                                [VSM] Erreur de conformité au volet VSM : La section "Traitement au long cours" (1.2.250.1.213.1.1.2.32) doit être présente.
                        </assert>
                </rule>
                
                <!-- [Modif 09/06/2020] Suppression de ce contrôle car la vérification est faite dans le schématron S_traitementAuLongCours_ASIP.sch 
                <rule context="cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section[cda:templateId[@root='1.2.250.1.213.1.1.2.32']]">
                        <assert test="cda:component/cda:section[cda:templateId[@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']]/cda:text"> 
                            [VSM] Erreur de conformité au volet VSM : Dans une section "Traitements" (1.3.6.1.4.1.19376.1.5.3.1.3.19) l'élément text est obligatoire.
                    </assert>
                </rule>
                -->
                
                <rule context="cda:ClinicalDocument">
                        <!-- Verifier la présence d'un participant pour le médecin traitant -->
                        <assert test="count(cda:participant[@typeCode='INF']/cda:functionCode[@code='PCP']) =1                                  and count(cda:participant[@typeCode='INF']/cda:functionCode[@displayName='Médecin Traitant']) =1                                                                                                                  and count(cda:participant[@typeCode='INF']/cda:functionCode[@codeSystem='2.16.840.1.113883.5.88']) =1">
                                [VSM] Un participant pour le médecin traitant est obligatoire avec typeCode='INF' et functionCode@code='PCP', functionCode@displayName='Médecin Traitant' et functionCode@codeSystem='2.16.840.1.113883.5.88'.
                        </assert>
                </rule>
                
                <rule context="cda:ClinicalDocument">
                        <!-- Vérifier le contenu des attributs de l'acte documenté -->
                        <assert test="(cda:documentationOf/cda:serviceEvent/cda:code[@code='34117-2'])                                  and (cda:documentationOf/cda:serviceEvent/cda:code[@displayName='Historique et clinique'])                                                                                                                   and (cda:documentationOf/cda:serviceEvent/cda:code[@codeSystem='2.16.840.1.113883.6.1'])                                                                                                               and (cda:documentationOf/cda:serviceEvent/cda:code[@codeSystemName='LOINC'])">
                                [VSM] L'acte documenté doit être documentationOf/serviceEvent/code@code='34117-2', @displayName='Historique et clinique', @codeSystem='2.16.840.1.113883.6.1' et @codeSystemName='LOINC'.
                        </assert>
                </rule>
                
        </pattern>
</schema>