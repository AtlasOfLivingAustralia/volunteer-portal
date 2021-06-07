// Mappings for expedition labels, icons, etc
expedition = [
        [name: "Expedition Leader",
         icons: [
                 [
                         icon: "images/team/teamExpeditionLeader.png",
                         link: "",
                         name: "",
                         bio:  ""
                 ],
                 [
                         icon: "images/explorers/GerardKrefft.png",
                         link: "http://www.australianmuseum.net.au/image/Gerard-Krefft/",
                         name: "Gerard Krefft (1830-1881)",
                         bio: "In June 1860 Kreft was appointed Assistant Curator of the Australian Museum, then acting Curator and Secretary after Simon Rood Pittard's death.Krefft built up the Museum's collections and won international repute as a scientist, corresponding with Charles Darwin, Sir Richard Owen and Albert Gunther of the British Museum. He was an early supporter of Darwin's theory of evolution. Krefft's discovery of the Queensland lungfish and its description in 1870, and his exploration of Wellington Caves in 1866, and writings of its fossils, are two of his significant achievements. During Krefft's time, Barnet's College Street extension to the building was erected (1861-1867)."
                 ],[
                         icon: "images/explorers/HelenaForde.png",
                         name: "Helena Forde (nee Scott) (1832-1910)",
                         link: "http://www.australianmuseum.net.au/A-biography-of-the-Scott-sisters/",
                         bio: "Helena and Harriet (known as the Scott sisters) were two of 19th century Australia’s most prominent natural history illustrators and possibly the first professional female illustrators in the country"
                 ],[
                         icon: "images/explorers/ElsieBrammel.png",
                         link: "",
                         name: "Elsie Bramell",
                         bio:  "Fred McCarthy and Elsie Bramell both worked at the Australian Museum during the 1930s. When the couple married in 1940, public service rules prohibiting married couples from working together meant that Elsie had to resign from her position at the Museum"
                 ],[
                         icon: "images/explorers/RobertEtheridge.png",
                         link: "http://www.australianmuseum.net.au/Curators-and-Directors-of-the-Australian-Museum/",
                         name: "Robert Etheridge Jnr (1846-1920)",
                         bio:  "Robert Etheridge Jnr trained as a palaeontologist and was appointed curator of the Australian Museum in 1895. During his time, the museum building was enlarged with the erection of the south wing, public lectures resumed and cadetships were introduced."
                 ],[
                         icon: "images/explorers/GeorgeBennet.png",
                         link: "http://www.australianmuseum.net.au/Curators-and-Directors-of-the-Australian-Museum/",
                         name: "Dr George Bennett (1804-1893)",
                         bio:  "George Bennett, a distinguished naturalist and medical practitioner, travelled extensively, visiting Sydney in 1829 and 1832, before settling there in 1835. Bennett lobbied for the position of Curator at the fledgling Museum, and was appointed in 1835. His major achievement was the publication in 1837 of the first published 'Catalogue of Specimens of Natural History and Miscellaneous Curiosities deposited in the Australian Museum', which then comprised 36 mammal species, 317 Australian birds and 25 exotic birds, 15 reptiles, 6 fishes, 211 insects, 25 shells, 57 foreign fossils and 25 'native ornaments, weapons, utensils'."
                 ]
         ],
         max: 1,
         threshold: 1],
        [name: "Scientists",
         icons: [
                 [
                         icon: "images/team/teamScientist.png",
                         link: "",
                         name: "Expedition Scientist",
                         bio: ""
                 ],[
                         icon:"images/explorers/EdwardPiersonRamsay.png",
                         name: "Edward Pierson Ramsay",
                         link: "http://www.australianmuseum.net.au/image/Edward-Pierson-Ramsay/",
                         bio: "Curator of the Australian Museum 1874-1894"
                 ]
         ],
         max: 9999,
         threshold: 50],
        [name: "Collection Managers",
         icons: [
                 [
                         icon: "images/team/teamCollectionsManager.png",
                         link: "",
                         name: "Expedition Collections Manager",
                         bio: ""
                 ],[
                         icon: "images/explorers/SusanEmilyNaegueli.png",
                         link: "http://www.australianmuseum.net.au/Harry-Burrell-Glass-Plate-Negative-Collection/",
                         name: "Susan Emily Naegueli",
                         bio:  "Susan Emily Naegueli, also known as Mrs Harry Burrell. Harry Burrell invented the ‘platypussary’ and referred to himself as the ‘platypoditudinarian’.  Susan worked with Harry on his research and was also a naturalist in her own right, lecturing to school and other groups on monotremes."
                 ]
         ],
         max: 9999,
         threshold: 10],
        [name: "Technical Officers",
         icons: [
                 [
                         icon: "images/team/teamTechnicalOfficer.png",
                         link: "",
                         name: "Expedition Technical Officer",
                         bio: ""
                 ],[
                         icon: "images/explorers/WilliamSheridanWall.png",
                         name: "William Sheridan Wall",
                         link: "http://www.australianmuseum.net.au/image/William-Sheridan-Wall/",
                         bio: "Curator of the Australian Museum c. 1844-1858"
                 ]
         ],
         max: 9999,
         threshold: 1
        ]

]

grails.mime.use.accept.header = true

grails {
    cache {
        enabled = true
        ehcache {
            cacheManagerName = 'digivol-cache-manager'
            ehcacheXmlLocation = 'classpath:digivol-ehcache.xml' // conf/ehcache.xml
            reloadable = false
        }

    }
    gorm {
        'default' {
            mapping = {
                autowire: true
            }
        }
    }
//    gorm {
//        'default' {
//            mapping = {
//                id generator: 'org.hibernate.id.enhanced.SequenceStyleGenerator', params: [prefer_sequence_per_entity: true]
//            }
//        }
//    }
}
