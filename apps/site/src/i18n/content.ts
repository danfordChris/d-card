// Copy for the marketing site. Swahili first (WEB-1). Prices and plan contents follow
// docs/design/features/plans-and-billing.md — update both together.

export type Lang = "sw" | "en";

export type Plan = { name: string; price: string; tag?: string; lead: string; items: string[] };

export type Content = {
  meta: { title: string; description: string };
  nav: { how: string; features: string; pricing: string; faq: string; cta: string; switchTo: string };
  hero: { kicker: string; title: string; body: string; cta: string; secondary: string; points: string[] };
  how: { title: string; steps: { title: string; body: string }[] };
  features: { title: string; intro: string; items: { title: string; body: string }[] };
  samples: { title: string; body: string; alt: (type: string) => string; types: Record<string, string> };
  pricing: { title: string; intro: string; perCard: string; plans: Plan[]; rules: string[]; cta: string };
  faq: { title: string; items: { q: string; a: string }[] };
  contact: { title: string; body: string; whatsapp: string; call: string; email: string; start: string };
  footer: { tagline: string; rights: string };
};

const sw: Content = {
  meta: {
    title: "D-Card — Kadi za mwaliko za kidigitali, michango na mlangoni",
    description:
      "Tuma kadi za mwaliko kwa WhatsApp na SMS, fuatilia michango, na hakiki wageni mlangoni kwa QR hata bila mtandao. Kuanzia Tsh 1,000 kwa kadi.",
  },
  nav: { how: "Inavyofanya kazi", features: "Huduma", pricing: "Bei", faq: "Maswali", cta: "Anza sasa", switchTo: "English" },
  hero: {
    kicker: "Harusi · Send-off · Kitchen party · Mahafali",
    title: "Kadi za mwaliko, michango na mlangoni — mahali pamoja.",
    body: "Wageni wanapokea kadi kwa WhatsApp na SMS. Mchango ukikamilika, kadi inatumwa yenyewe. Siku ya tukio, walinzi wanaskani QR hata mtandao ukikatika.",
    cta: "Tengeneza tukio lako",
    secondary: "Angalia bei",
    points: ["Hakuna simu janja? SMS inafika", "Pesa za michango haziguswi na D-Card", "Kiswahili na Kiingereza"],
  },
  how: {
    title: "Inavyofanya kazi",
    steps: [
      { title: "1. Tengeneza tukio", body: "Chagua kifurushi, weka tarehe, ukumbi na namba ya mhusika wa tukio. Dakika chache tu." },
      { title: "2. Ongeza wageni na wachangiaji", body: "Mmoja mmoja, kutoka Excel, kutoka simu yako, au nakili kutoka tukio lililopita." },
      { title: "3. Kadi zinajituma", body: "Mchango ukikamilika au ukitoa kadi, mgeni anapokea kadi yenye QR. Mlangoni, skani na umemaliza." },
    ],
  },
  features: {
    title: "Kila kitu kwa tukio lako",
    intro: "Imejengwa kwa jinsi kamati za Tanzania zinavyofanya kazi.",
    items: [
      { title: "WhatsApp na SMS", body: "Kila ujumbe unaenda kwa njia zote mbili, kwa hiyo hata wenye simu za kawaida wanapata kadi na namba yao." },
      { title: "Michango bila makaratasi", body: "Ahadi, malipo, salio na ziada. Mhazini anarekodi malipo; asante na salio vinatumwa, na kadi inatoka yenyewe." },
      { title: "Mlangoni hata bila mtandao", body: "App ya D-Card Door inaskani QR au namba ya kadi, inazuia kadi kutumika mara mbili, na inasawazisha mtandao ukirudi." },
      { title: "Uthibitisho wa kuhudhuria", body: "Wageni wanabonyeza Ndiyo au Hapana kwenye WhatsApp. Unajua idadi halisi ya chakula na viti." },
      { title: "Timu yako", body: "Mweka hazina, kamati na walinzi wa mlangoni kila mmoja na ruhusa zake. Unawaalika kwa kiungo." },
      { title: "Picha kwenye Google Drive yako", body: "Kwenye Kawaida na Premium, picha na video za wageni zinakaa kwenye Drive yako — wewe ndiye mmiliki." },
    ],
  },
  samples: {
    title: "Kadi halisi, tayari kwa WhatsApp",
    body: "Kila mgeni anapata kadi yake yenye jina, tarehe, ukumbi, namba ya kadi na QR.",
    alt: (type) => `Mfano wa kadi ya ${type} yenye QR na namba ya kadi`,
    types: { wedding: "Harusi", send_off: "Send-off", kitchen_party: "Kitchen party", graduation: "Mahafali" },
  },
  pricing: {
    title: "Bei kwa kila kadi ya mgeni",
    intro: "Kadi ya mtu mmoja au wawili — bei ni ile ile. Ujumbe wote umejumuishwa.",
    perCard: "kwa kadi",
    plans: [
      {
        name: "Msingi",
        price: "1,000",
        lead: "Kila kitu cha msingi kwa tukio lako.",
        items: [
          "Kadi kwa WhatsApp na SMS, QR na namba ya kadi",
          "Michango: ahadi, malipo, salio, kadi inajituma",
          "RSVP, uthibitisho na kumbusho la tukio",
          "D-Card Door mlangoni (mtandaoni na bila mtandao)",
          "Walinzi 2 wa mlangoni",
          "Kiungo cha albamu ya Google Photos",
        ],
      },
      {
        name: "Kawaida",
        price: "1,500",
        tag: "Kinachopendwa zaidi",
        lead: "Msingi, pamoja na udhibiti kamili wa ujumbe na picha.",
        items: [
          "Kadi inapanda Moja → Mbili yenyewe",
          "Makumbusho 3 ya michango kwa kila mchangiaji",
          "Chagua njia na maneno ya kila ujumbe",
          "Picha 5 + video kwenye kadi, ukurasa wa hadithi",
          "Picha za wageni kwenye Google Drive yako",
          "Walinzi 5 wa mlangoni",
        ],
      },
      {
        name: "Premium",
        price: "2,000",
        lead: "Kawaida, pamoja na kadi ya video na zaidi.",
        items: [
          "Kadi ya video yenye muziki",
          "Makumbusho 6 ya michango",
          "Ujumbe wa asante baada ya tukio",
          "Slideshow ya picha ukumbini",
          "Walinzi wa mlangoni bila kikomo",
        ],
      },
    ],
    rules: [
      "Kiwango cha chini: Tsh 50,000 kwa tukio (mf. kadi 50 za Msingi).",
      "Punguzo la 20% kwenye tukio lako la kwanza.",
      "Unaongeza wageni kwa vifurushi vya 10 wakati wowote, na unapandisha kifurushi wakati wowote.",
      "Unalipa kwa simu (M-Pesa, Mixx by Yas, Airtel Money, HaloPesa) kabla kadi hazijatumwa.",
    ],
    cta: "Anza na tukio lako",
  },
  faq: {
    title: "Maswali yanayoulizwa mara kwa mara",
    items: [
      { q: "Wageni wasio na simu janja watapata kadi?", a: "Ndiyo. Kila kadi inatumwa pia kwa SMS yenye namba ya kadi na mawasiliano ya mhusika. Mlangoni wanataja au kuonyesha namba hiyo." },
      { q: "Pesa za michango zinapita D-Card?", a: "Hapana. Wachangiaji wanalipa kamati moja kwa moja (M-Pesa, benki, taslimu). Mhazini anarekodi malipo kwenye D-Card, na kadi inatoka mchango ukikamilika." },
      { q: "Mtandao ukikatika siku ya tukio?", a: "D-Card Door inaendelea kuskani bila mtandao na inazuia kadi kutumika zaidi ya mara zake. Mtandao ukirudi, inasawazisha yenyewe." },
      { q: "Bei inahesabiwaje?", a: "Kwa kila kadi ya mgeni. Kadi ya watu wawili ni bei ile ile. Ujumbe wote wa WhatsApp na SMS umejumuishwa — hakuna gharama za ziada kwa ujumbe." },
      { q: "Mgeni akitaka kuacha kupokea ujumbe?", a: "Anajibu STOP kwenye WhatsApp. Hatapokea tena WhatsApp za tukio hilo; kadi yake bado itafika kwa SMS." },
      { q: "Picha za tukio zinahifadhiwa wapi?", a: "Kwenye Google Drive yako mwenyewe. D-Card haihifadhi picha wala video kwenye seva zake." },
    ],
  },
  contact: {
    title: "Tuko tayari kukusaidia",
    body: "Una tukio linakuja? Tuandikie, au anza mwenyewe sasa hivi.",
    whatsapp: "Tuandikie WhatsApp",
    call: "Piga simu",
    email: "Barua pepe",
    start: "Tengeneza tukio",
  },
  footer: { tagline: "Kadi za mwaliko za kidigitali, Tanzania.", rights: "Haki zote zimehifadhiwa." },
};

const en: Content = {
  meta: {
    title: "D-Card — Digital invitation cards, contributions and door check-in",
    description:
      "Send invitation cards by WhatsApp and SMS, track contributions, and check guests in at the door with QR — even offline. From Tsh 1,000 per card.",
  },
  nav: { how: "How it works", features: "Features", pricing: "Pricing", faq: "FAQ", cta: "Get started", switchTo: "Kiswahili" },
  hero: {
    kicker: "Weddings · Send-offs · Kitchen parties · Graduations",
    title: "Invitation cards, contributions and the door — in one place.",
    body: "Guests receive their card by WhatsApp and SMS. When a pledge is fully paid, the card sends itself. On the day, door staff scan QR codes even when the network drops.",
    cta: "Create your event",
    secondary: "See pricing",
    points: ["No smartphone? SMS still arrives", "D-Card never touches contribution money", "Swahili and English"],
  },
  how: {
    title: "How it works",
    steps: [
      { title: "1. Create your event", body: "Pick a plan, set the date, venue and your event contact. It takes a few minutes." },
      { title: "2. Add guests and contributors", body: "One by one, from Excel, from your phone contacts, or copied from a past event." },
      { title: "3. Cards send themselves", body: "When a pledge is complete or you issue a card, the guest receives a card with a QR code. At the door, scan and you're done." },
    ],
  },
  features: {
    title: "Everything your event needs",
    intro: "Built around how Tanzanian committees actually work.",
    items: [
      { title: "WhatsApp and SMS", body: "Every message goes on both channels, so guests with basic phones still get their card and number." },
      { title: "Contributions without paperwork", body: "Pledges, payments, balances and extras. The treasurer records payments; thank-you and balance messages go out, and the card issues itself." },
      { title: "Door check-in, even offline", body: "The D-Card Door app scans QR codes or card numbers, blocks double entry, and syncs when the network returns." },
      { title: "Attendance confirmation", body: "Guests tap Yes or No on WhatsApp. You know the real numbers for food and seating." },
      { title: "Your team", body: "Treasurer, committee and door staff, each with their own permissions. Invite them with a link." },
      { title: "Photos in your own Google Drive", body: "On Kawaida and Premium, guest photos and videos live in your Drive — you own them." },
    ],
  },
  samples: {
    title: "Real cards, ready for WhatsApp",
    body: "Every guest gets their own card with name, date, venue, card number and QR code.",
    alt: (type) => `Sample ${type} card with QR code and card number`,
    types: { wedding: "Wedding", send_off: "Send-off", kitchen_party: "Kitchen party", graduation: "Graduation" },
  },
  pricing: {
    title: "Priced per guest card",
    intro: "Single or double card — same price. All messages included.",
    perCard: "per card",
    plans: [
      {
        name: "Msingi",
        price: "1,000",
        lead: "Everything essential for your event.",
        items: [
          "Cards by WhatsApp and SMS, QR and card number",
          "Contributions: pledges, payments, balances, automatic cards",
          "RSVP, attendance confirmation and event reminder",
          "D-Card Door at the entrance (online and offline)",
          "2 door staff",
          "Google Photos album link",
        ],
      },
      {
        name: "Kawaida",
        price: "1,500",
        tag: "Most popular",
        lead: "Msingi, plus full message control and photos.",
        items: [
          "Automatic upgrade from Single to Double",
          "3 contribution reminders per contributor",
          "Choose the channel and wording of each message",
          "5 photos + video on the card, story page",
          "Guest photos in your Google Drive",
          "5 door staff",
        ],
      },
      {
        name: "Premium",
        price: "2,000",
        lead: "Kawaida, plus a video card and more.",
        items: ["Video card with music", "6 contribution reminders", "Thank-you message after the event", "Live photo slideshow at the venue", "Unlimited door staff"],
      },
    ],
    rules: [
      "Minimum: Tsh 50,000 per event (e.g. 50 Msingi cards).",
      "20% off your first event.",
      "Add guests in blocks of 10 at any time, and upgrade your plan at any time.",
      "Pay by mobile money (M-Pesa, Mixx by Yas, Airtel Money, HaloPesa) before cards are sent.",
    ],
    cta: "Start your event",
  },
  faq: {
    title: "Frequently asked questions",
    items: [
      { q: "Will guests without smartphones get a card?", a: "Yes. Every card is also sent by SMS with the card number and the event contact. At the door they show or say that number." },
      { q: "Does contribution money go through D-Card?", a: "No. Contributors pay the committee directly (M-Pesa, bank, cash). The treasurer records payments in D-Card, and the card issues when the pledge is complete." },
      { q: "What if the network fails on the day?", a: "D-Card Door keeps scanning offline and stops a card being used more than allowed. It syncs by itself when the network returns." },
      { q: "How is the price calculated?", a: "Per guest card. A double card costs the same. All WhatsApp and SMS messages are included — no per-message charges." },
      { q: "What if a guest wants to stop messages?", a: "They reply STOP on WhatsApp. They get no more WhatsApp messages for that event; their card still arrives by SMS." },
      { q: "Where are event photos stored?", a: "In your own Google Drive. D-Card does not store photos or videos on its servers." },
    ],
  },
  contact: {
    title: "We're ready to help",
    body: "Have an event coming up? Message us, or get started yourself right now.",
    whatsapp: "Message us on WhatsApp",
    call: "Call us",
    email: "Email",
    start: "Create an event",
  },
  footer: { tagline: "Digital invitation cards, Tanzania.", rights: "All rights reserved." },
};

export const content: Record<Lang, Content> = { sw, en };
