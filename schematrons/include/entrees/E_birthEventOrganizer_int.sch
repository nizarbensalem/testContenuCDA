<?xml version="1.0" encoding="UTF-8"?>

<!--                  -=<<o#%@O[ E_birthEventOrganizer_int.sch ]O@%#o>>=-
    
    Teste la conformité des entrées de la section "Birth Event Organizer" (1.3.6.1.4.1.19376.1.5.3.1.4.13.5.2)
    aux spécifications d'IHE PCC v3.0
    
    Historique :
    28/10/2013 : CRI : Création E_birthEventOrganizer_int.sch
   30/01/2020 : NMA : Suppression du test sur le nombre de templateId
    
-->

<pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="E_birthEventOrganizer_int">
  
    <rule context='*[cda:templateId/@root="1.3.6.1.4.1.19376.1.5.3.1.4.13.5.2"]'>  
        
        <let name="count_templateId" value="count(cda:templateId)"/>
        
        <assert test="self::cda:organizer[@classCode='CLUSTER' and @moodCode='EVN']">
            [E_birthEventOrganizer_int] : Cette entrée est un cluster d'observations à propos d'un événement d'accouchement.
        </assert>
        
        <assert test="cda:id">
            [E_birthEventOrganizer_int] Erreur de conformité PCC : Dans l'élément "Birth Event Organizer", un élément "id" doit obligatoirement être présent
        </assert>
        
        <assert test="cda:code">
            [E_birthEventOrganizer_int] Erreur de conformité PCC : Dans l'élément "Birth Event Organizer", un élément "code" doit obligatoirement être présent
        </assert>
        
        <assert test="cda:author">
            [E_birthEventOrganizer_int] : Un organizer "Birth Event Organizer" doit contenir un auteur pour représenter la personne ou le dispositif
        </assert>
 
        <assert test="cda:subject[@typeCode='SBJ']">
            [E_birthEventOrganizer_int] : Un organizer "Birth Event Organizer" doit contenir un élément "subject" pour décrire le nouveau né
        </assert>
        
        <assert test="cda:component/cda:observation/cda:templateId[@root='1.3.6.1.4.1.19376.1.5.3.1.4.13.5']">
            [E_birthEventOrganizer_int] : Un organizer "Birth Event Organizer" doit contenir au moins un élément component de type Pregnancy Observation
        </assert>
        
        <report test="(cda:component/cda:observation/cda:templateId[@root!='1.3.6.1.4.1.19376.1.5.3.1.4.13.5' and @root!='1.3.6.1.4.1.19376.1.5.3.1.4.13'])">
            [E_birthEventOrganizer_int] : Un organizer "Birth Event Organizer" ne doit pas contenir d'éléments component de type autre que Pregnancy Observation
        </report>
               
    </rule>
</pattern>