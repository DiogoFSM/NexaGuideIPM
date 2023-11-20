import 'package:nexaguide_ipm/database/nexaguide_db.dart';

class InitializePOIandEvents {

  static Future<void> initPOI() async {
    var database = NexaGuideDB();

    database.createPOIWithTagsAndImages(
        name: "FCT NOVA",
        lat: 38.66098,
        lng: -9.20443,
        address: "Largo da Torre, 2829-516 Caparica",
        website: "https://www.fct.unl.pt/",
        price: -1,
        description: "Universidade Nova de Lisboa - Faculdade de Ciências e Tecnologia",
        tags:["Cultural"],
        photoURLs: [
          "https://www.fct.unl.pt/sites/default/files/imagens/noticias/2015/03/DSC_5142_Tratado.jpg",
          "https://arquivo.codingfest.fct.unl.pt/2016/sites/www.codingfest.fct.unl.pt/files/imagens/fctnova.jpeg",
          "https://www.fct.unl.pt/sites/default/files/imagecache/l740/imagens/noticias/2021/02/campusfct.png",
        ],
        cityID: 3595
    );

    database.createPOIWithTagsAndImages(
        name: "Torre de Belém",
        lat: 38.691623,
        lng:  -9.215953,
        address: "Av. Brasília, 1400-038 Lisboa",
        website: "https://torrebelem.com/pt/",
        price: 9,
        description: "A Torre de Belém fica na cidade de Lisboa, Portugal no sul da Europa. Este monumento foi erguido com a finalidade de servir quer como porta de entrada na cidade de Lisboa, quer como sistema de defesa contra possíveis invasões e ataques vindos do Tejo.",
        tags:["Historical", "Cultural"],
        photoURLs: [
          "https://cdn-imgix.headout.com/microbrands-content-image/image/f94caf06c3d6d7779a089fea20611e99-AdobeStock_314194172.jpeg",
          "https://www.atlantistour.pt/wp-content/uploads/2015/07/TORRE-DE-BEL%C3%89M.jpg"
        ],
        cityID: 295
    );

    database.createPOIWithTagsAndImages(
        name: "Pasteis de Belém",
        lat: 38.69750378716137,
        lng: -9.20322526655013,
        address: "Rua de Belém 84 92, 1300-085 Lisboa",
        website: "https://pasteisdebelem.pt/",
        price: -1,
        description: "A Antiga Confeitaria de Belém consegue proporcionar hoje o paladar da antiga doçaria portuguesa.",
        tags:["Restaurant", "Historical"],
        photoURLs: [
          "https://lisboacool.com/sites/default/files/styles/ny_article_horizontal__w720xh480_watermark/public/lisboa_cool_comer_pasteis_de_belem60.jpg?itok=2jeOrXje",
        ],
        cityID: 295
    );

    database.createPOIWithTagsAndImages(
        name: "Centro Cultural de Belém",
        lat: 38.695470953470206,
        lng: -9.208347077646973,
        address: "Praça do Império, 1449-003 Lisboa",
        website: "https://www.ccb.pt/Default/pt/Inicio",
        price: -1,
        description: "O Centro Cultural de Belém (CCB) localiza-se na praça do Império, freguesia de Belém, na cidade e no município de Lisboa, no distrito de Lisboa, em Portugal. Foi concebido originalmente para acolher a sede da presidência portuguesa da União Europeia e posteriormente para desenvolver atividade cultural. Atualmente alberga o Museu de Arte Contemporânea - Centro Cultural de Belém, entre outros equipamentos culturais. ",
        tags:["Cultural"],
        photoURLs: [
          "https://bestexperiencelisbon.com/wp-content/uploads/2016/05/Centro-cultura-de-bel%C3%A9m-1.jpg",
          "https://upload.wikimedia.org/wikipedia/commons/4/44/Lisboa_-_Portugal_%28204238418%29.jpg",
        ],
        cityID: 295
    );

    database.createPOIWithTagsAndImages(
        name: "Jardim da Praça do Império",
        lat: 38.69611018687747,
        lng: -9.20595861406561,
        address: "Praça do Império, 1400-206 Lisboa",
        price: -1,
        description: "Jardim construído por altura da Exposição do Mundo Português (1940), evento comemorativo dos 800 anos da Independência de Portugal e dos 300 anos da Restauração da Independência, da autoria do arquiteto Cottineli Telmo. É também desta época a Fonte Luminosa existente no centro do jardim.",
        tags:["Outdoors"],
        photoURLs: [
          "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/09/11/70/d6/jardim-da-praca-do-imperio.jpg?w=1200&h=-1&s=1",
        ],
        cityID: 295
    );

    database.createPOIWithTags(
        name: "Passeio Marítimo de Algés",
        lat: 38.697422,
        lng: -9.231721,
        price: -1,
        description: "",
        tags:["Outdoors"],
        cityID: 295
    );

    /*
    database.createPOIWithTags(
        name: "Herdade da Casa Branca",
        lat: 38.697422,
        lng: -9.231721,
        price: -1,
        description: "",
        tags:["Outdoors"],
        cityID: 295
    );
     */

  }

  static Future<void> initEvents() async {
    var database = NexaGuideDB();

    database.createEventWithTags(
        name: "Semana do Caloiro",
        poiID: 1,
        dateStart: 1694563200000,
        dateEnd: 1694822400000,
        location: "Caparica",
        startTime: "20:00h",
        endTime: "04:00h",
        price: 16,
        tags: ["Festival"]
    );

    database.createEventWithTags(
        name: "NOS Alive 2024",
        poiID: 6,
        dateStart: 1720659600000,
        dateEnd: 1720911600000,
        location: "Lisbon",
        startTime: "20:00h",
        endTime: "04:00h",
        price: 79,
        description: " O NOS Alive regressa ao Passeio Marítimo de Algés, nos dias 11, 12 e 13 de julho, no ano em que celebra a sua 16ª edição.",
        tags: ["Festival"]
    );
  }

}

