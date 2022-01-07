<?xml version="1.0" encoding="UTF-8"?>

<!-- Schématron du document CNAM-HR (Historique des remboursements) : CI-SIS_CNAM-HR_2020.01.sch
        
        Auteur : ANS 
        Historique :
        16/10/2019 : Création
        03/09/2020 : Ajoût du contrôle de la présence obligatoire de la section "Section Commentaire" (1.3.6.1.4.1.19376.1.4.1.2.16) 
-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" defaultPhase="CI-SIS_CNAM-HR_2020.01"
        xmlns:cda="urn:hl7-org:v3" queryBinding="xslt2"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" schemaVersion="CI-SIS_CNAM-HR_2020.01.sch">

        <title>Rapport de conformité du document aux spécifications du volet CNAM-HR_2020.01</title>
        <ns prefix="cda" uri="urn:hl7-org:v3"/>
        <ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
        <ns prefix="jdv" uri="http://esante.gouv.fr"/>
        <ns prefix="svs" uri="urn:ihe:iti:svs:2008"/>

        <!--  Abstract patterns  -->
        <include href="abstract/dansJeuDeValeurs.sch"/>
        <include href="abstract/IVL_TS.sch"/>

        <phase id="CI-SIS_CNAM-HR_2020.01">
                <active pattern="variables"/>
                <p>Vérification complète de la conformité au CI-SIS</p>
        </phase>
        <pattern id="variables">
                
                <rule context="cda:ClinicalDocument/cda:component/cda:structuredBody">
                        <assert test="cda:component/cda:section/cda:templateId[@root='1.3.6.1.4.1.19376.1.4.1.2.16']"> 
                                [CI-SIS_CNAM-HR] Erreur de conformité au modèle CNAM-HR : La section "Section Commentaire" (1.3.6.1.4.1.19376.1.4.1.2.16) pour la mention Usage et Responsabilités" doit être présente.
                        </assert>
                        <assert test="cda:component/cda:section/cda:templateId[@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']"> 
                                [CI-SIS_CNAM-HR] Erreur de conformité au volet CNAM-HR : La section "Traitements" (1.3.6.1.4.1.19376.1.5.3.1.3.19) doit être présente.
                        </assert>
                        <assert test="cda:component/cda:section/cda:templateId[@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']"> 
                                [CI-SIS_CNAM-HR] Erreur de conformité au volet CNAM-HR : La section "Vaccinations" (1.3.6.1.4.1.19376.1.5.3.1.3.23) doit être présente.
                        </assert>
                        <assert test="cda:component/cda:section/cda:templateId[@root='1.2.250.1.213.1.1.2.1']"> 
                                [CI-SIS_CNAM-HR] Erreur de conformité au volet CNAM-HR : La section "Dispositifs médicaux" (1.2.250.1.213.1.1.2.1) doit être présente.
                        </assert>
                        <assert test="cda:component/cda:section/cda:templateId[@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']"> 
                                [CI-SIS_CNAM-HR] Erreur de conformité au volet CNAM-HR : La section "Historique des prises en charge médicales (Hospitalisations)" (1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3) doit être présente.
                        </assert>
                        <assert test="cda:component/cda:section[cda:code/cda:translation[@code='67803-7']]/cda:templateId[@root='1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11']"> 
                                [CI-SIS_CNAM-HR] Erreur de conformité au volet CNAM-HR : La section "Actes et interventions (Soins médicaux ou dentaires)" (1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11) doit être présente avec un code/translation="67803-7".
                        </assert>
                        <assert test="cda:component/cda:section[cda:code/cda:translation[@code='18726-0']]/cda:templateId[@root='1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11']"> 
                                [CI-SIS_CNAM-HR] Erreur de conformité au volet CNAM-HR : La section "Actes et interventions (Radiologie)" (1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11) doit être présente avec un code/translation="18726-0".
                        </assert>
                        <assert test="cda:component/cda:section[cda:code/cda:translation[@code='26436-6']]/cda:templateId[@root='1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11']"> 
                                [CI-SIS_CNAM-HR] Erreur de conformité au volet CNAM-HR : La section "Actes et interventions (Biologie)" (1.3.6.1.4.1.19376.1.5.3.1.1.13.2.11) doit être présente avec un code/translation="26436-6".
                        </assert>
                </rule>
                
        </pattern>
</schema>
