<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    S_FR-CR-de-biologie-code.sch :
    
    Contrôle du code de la section de 1er niveau FR-CR-de-biologie (1.3.6.1.4.1.19376.1.3.3.2.1)
        
    Historique :
    13/01/2021 : Création
-->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="S_FR-CR-de-biologie-code" is-a="dansJeuDeValeurs">
    <p>Conformité du code d'une section de 1er niveau dans un CR de biologie / jeu de valeurs chapitresBiologie</p>
    <param name="path_jdv" value="$JDV_BIO_Chapitres-CISIS"/>
    <param name="vue_elt" value="'ClinicalDocument/component/structuredBody/component/section/code'"/>
    <param name="xpath_elt" value="cda:structuredBody/cda:component/cda:section[cda:templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/cda:code"/>
    <param name="nullFlavor" value="1"/>
</pattern>   
