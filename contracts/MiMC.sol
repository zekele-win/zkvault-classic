// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// REF: https://gist.github.com/poma/5adb51d49057d0a0edad2cbd12945ac4

library MiMC {
    uint256 private constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    function MiMCFeistel(
        uint256 xL,
        uint256 xR,
        uint256 cPartial
    ) private pure returns (uint256, uint256) {
        uint256 t = addmod(xL, cPartial, FIELD_SIZE);

        uint256 exp = mulmod(t, t, FIELD_SIZE);
        exp = mulmod(exp, exp, FIELD_SIZE);
        exp = mulmod(exp, t, FIELD_SIZE);

        uint256 xR_tmp = xR;
        xR = xL;
        xL = addmod(xR_tmp, exp, FIELD_SIZE);

        return (xL, xR);
    }

    function MiMCSponge(
        uint256 xL,
        uint256 xR
    ) private pure returns (uint256, uint256) {
        uint256 exp;
        uint256 t;
        uint256 xR_tmp;

        t = xL;
        exp = mulmod(t, t, FIELD_SIZE);
        exp = mulmod(exp, exp, FIELD_SIZE);
        exp = mulmod(exp, t, FIELD_SIZE);
        xR_tmp = xR;
        xR = xL;
        xL = addmod(xR_tmp, exp, FIELD_SIZE);

        (xL, xR) = MiMCFeistel(xL, xR, 7120861356467848435263064379192047478074060781135320967663101236819528304084);
        (xL, xR) = MiMCFeistel(xL, xR, 5024705281721889198577876690145313457398658950011302225525409148828000436681);
        (xL, xR) = MiMCFeistel(xL, xR, 17980351014018068290387269214713820287804403312720763401943303895585469787384);
        (xL, xR) = MiMCFeistel(xL, xR, 19886576439381707240399940949310933992335779767309383709787331470398675714258);
        (xL, xR) = MiMCFeistel(xL, xR, 1213715278223786725806155661738676903520350859678319590331207960381534602599);
        (xL, xR) = MiMCFeistel(xL, xR, 18162138253399958831050545255414688239130588254891200470934232514682584734511);
        (xL, xR) = MiMCFeistel(xL, xR, 7667462281466170157858259197976388676420847047604921256361474169980037581876);
        (xL, xR) = MiMCFeistel(xL, xR, 7207551498477838452286210989212982851118089401128156132319807392460388436957);
        (xL, xR) = MiMCFeistel(xL, xR, 9864183311657946807255900203841777810810224615118629957816193727554621093838);
        (xL, xR) = MiMCFeistel(xL, xR, 4798196928559910300796064665904583125427459076060519468052008159779219347957);
        (xL, xR) = MiMCFeistel(xL, xR, 17387238494588145257484818061490088963673275521250153686214197573695921400950);
        (xL, xR) = MiMCFeistel(xL, xR, 10005334761930299057035055370088813230849810566234116771751925093634136574742);
        (xL, xR) = MiMCFeistel(xL, xR, 11897542014760736209670863723231849628230383119798486487899539017466261308762);
        (xL, xR) = MiMCFeistel(xL, xR, 16771780563523793011283273687253985566177232886900511371656074413362142152543);
        (xL, xR) = MiMCFeistel(xL, xR, 749264854018824809464168489785113337925400687349357088413132714480582918506);
        (xL, xR) = MiMCFeistel(xL, xR, 3683645737503705042628598550438395339383572464204988015434959428676652575331);
        (xL, xR) = MiMCFeistel(xL, xR, 7556750851783822914673316211129907782679509728346361368978891584375551186255);
        (xL, xR) = MiMCFeistel(xL, xR, 20391289379084797414557439284689954098721219201171527383291525676334308303023);
        (xL, xR) = MiMCFeistel(xL, xR, 18146517657445423462330854383025300323335289319277199154920964274562014376193);
        (xL, xR) = MiMCFeistel(xL, xR, 8080173465267536232534446836148661251987053305394647905212781979099916615292);
        (xL, xR) = MiMCFeistel(xL, xR, 10796443006899450245502071131975731672911747129805343722228413358507805531141);
        (xL, xR) = MiMCFeistel(xL, xR, 5404287610364961067658660283245291234008692303120470305032076412056764726509);
        (xL, xR) = MiMCFeistel(xL, xR, 4623894483395123520243967718315330178025957095502546813929290333264120223168);
        (xL, xR) = MiMCFeistel(xL, xR, 16845753148201777192406958674202574751725237939980634861948953189320362207797);
        (xL, xR) = MiMCFeistel(xL, xR, 4622170486584704769521001011395820886029808520586507873417553166762370293671);
        (xL, xR) = MiMCFeistel(xL, xR, 16688277490485052681847773549197928630624828392248424077804829676011512392564);
        (xL, xR) = MiMCFeistel(xL, xR, 11878652861183667748838188993669912629573713271883125458838494308957689090959);
        (xL, xR) = MiMCFeistel(xL, xR, 2436445725746972287496138382764643208791713986676129260589667864467010129482);
        (xL, xR) = MiMCFeistel(xL, xR, 1888098689545151571063267806606510032698677328923740058080630641742325067877);
        (xL, xR) = MiMCFeistel(xL, xR, 148924106504065664829055598316821983869409581623245780505601526786791681102);
        (xL, xR) = MiMCFeistel(xL, xR, 18875020877782404439294079398043479420415331640996249745272087358069018086569);
        (xL, xR) = MiMCFeistel(xL, xR, 15189693413320228845990326214136820307649565437237093707846682797649429515840);
        (xL, xR) = MiMCFeistel(xL, xR, 19669450123472657781282985229369348220906547335081730205028099210442632534079);
        (xL, xR) = MiMCFeistel(xL, xR, 5521922218264623411380547905210139511350706092570900075727555783240701821773);
        (xL, xR) = MiMCFeistel(xL, xR, 4144769320246558352780591737261172907511489963810975650573703217887429086546);
        (xL, xR) = MiMCFeistel(xL, xR, 10097732913112662248360143041019433907849917041759137293018029019134392559350);
        (xL, xR) = MiMCFeistel(xL, xR, 1720059427972723034107765345743336447947522473310069975142483982753181038321);
        (xL, xR) = MiMCFeistel(xL, xR, 6302388219880227251325608388535181451187131054211388356563634768253301290116);
        (xL, xR) = MiMCFeistel(xL, xR, 6745410632962119604799318394592010194450845483518862700079921360015766217097);
        (xL, xR) = MiMCFeistel(xL, xR, 10858157235265583624235850660462324469799552996870780238992046963007491306222);
        (xL, xR) = MiMCFeistel(xL, xR, 20241898894740093733047052816576694435372877719072347814065227797906130857593);
        (xL, xR) = MiMCFeistel(xL, xR, 10165780782761211520836029617746977303303335603838343292431760011576528327409);
        (xL, xR) = MiMCFeistel(xL, xR, 2832093654883670345969792724123161241696170611611744759675180839473215203706);
        (xL, xR) = MiMCFeistel(xL, xR, 153011722355526826233082383360057587249818749719433916258246100068258954737);
        (xL, xR) = MiMCFeistel(xL, xR, 20196970640587451358539129330170636295243141659030208529338914906436009086943);
        (xL, xR) = MiMCFeistel(xL, xR, 3180973917010545328313139835982464870638521890385603025657430208141494469656);
        (xL, xR) = MiMCFeistel(xL, xR, 17198004293191777441573635123110935015228014028618868252989374962722329283022);
        (xL, xR) = MiMCFeistel(xL, xR, 7642160509228669138628515458941659189680509753651629476399516332224325757132);
        (xL, xR) = MiMCFeistel(xL, xR, 19346204940546791021518535594447257347218878114049998691060016493806845179755);
        (xL, xR) = MiMCFeistel(xL, xR, 11501810868606870391127866188394535330696206817602260610801897042898616817272);
        (xL, xR) = MiMCFeistel(xL, xR, 3113973447392053821824427670386252797811804954746053461397972968381571297505);
        (xL, xR) = MiMCFeistel(xL, xR, 6545064306297957002139416752334741502722251869537551068239642131448768236585);
        (xL, xR) = MiMCFeistel(xL, xR, 5203908808704813498389265425172875593837960384349653691918590736979872578408);
        (xL, xR) = MiMCFeistel(xL, xR, 2246692432011290582160062129070762007374502637007107318105405626910313810224);
        (xL, xR) = MiMCFeistel(xL, xR, 11760570435432189127645691249600821064883781677693087773459065574359292849137);
        (xL, xR) = MiMCFeistel(xL, xR, 5543749482491340532547407723464609328207990784853381797689466144924198391839);
        (xL, xR) = MiMCFeistel(xL, xR, 8837549193990558762776520822018694066937602576881497343584903902880277769302);
        (xL, xR) = MiMCFeistel(xL, xR, 12855514863299373699594410385788943772765811961581749194183533625311486462501);
        (xL, xR) = MiMCFeistel(xL, xR, 5363660674689121676875069134269386492382220935599781121306637800261912519729);
        (xL, xR) = MiMCFeistel(xL, xR, 13162342403579303950549728848130828093497701266240457479693991108217307949435);
        (xL, xR) = MiMCFeistel(xL, xR, 916941639326869583414469202910306428966657806899788970948781207501251816730);
        (xL, xR) = MiMCFeistel(xL, xR, 15618589556584434434009868216186115416835494805174158488636000580759692174228);
        (xL, xR) = MiMCFeistel(xL, xR, 8959562060028569701043973060670353733575345393653685776974948916988033453971);
        (xL, xR) = MiMCFeistel(xL, xR, 16390754464333401712265575949874369157699293840516802426621216808905079127650);
        (xL, xR) = MiMCFeistel(xL, xR, 168282396747788514908709091757591226095443902501365500003618183905496160435);
        (xL, xR) = MiMCFeistel(xL, xR, 8327443473179334761744301768309008451162322941906921742120510244986704677004);
        (xL, xR) = MiMCFeistel(xL, xR, 17213012626801210615058753489149961717422101711567228037597150941152495100640);
        (xL, xR) = MiMCFeistel(xL, xR, 10394369641533736715250242399198097296122982486516256408681925424076248952280);
        (xL, xR) = MiMCFeistel(xL, xR, 17784386835392322654196171115293700800825771210400152504776806618892170162248);
        (xL, xR) = MiMCFeistel(xL, xR, 16533189939837087893364000390641148516479148564190420358849587959161226782982);
        (xL, xR) = MiMCFeistel(xL, xR, 18725396114211370207078434315900726338547621160475533496863298091023511945076);
        (xL, xR) = MiMCFeistel(xL, xR, 7132325028834551397904855671244375895110341505383911719294705267624034122405);
        (xL, xR) = MiMCFeistel(xL, xR, 148317947440800089795933930720822493695520852448386394775371401743494965187);
        (xL, xR) = MiMCFeistel(xL, xR, 19001050671757720352890779127693793630251266879994702723636759889378387053056);
        (xL, xR) = MiMCFeistel(xL, xR, 18824274411769830274877839365728651108434404855803844568234862945613766611460);
        (xL, xR) = MiMCFeistel(xL, xR, 12771414330193951156383998390424063470766226667986423961689712557338777174205);
        (xL, xR) = MiMCFeistel(xL, xR, 11332046574800279729678603488745295198038913503395629790213378101166488244657);
        (xL, xR) = MiMCFeistel(xL, xR, 9607550223176946388146938069307456967842408600269548190739947540821716354749);
        (xL, xR) = MiMCFeistel(xL, xR, 8756385288462344550200229174435953103162307705310807828651304665320046782583);
        (xL, xR) = MiMCFeistel(xL, xR, 176061952957067086877570020242717222844908281373122372938833890096257042779);
        (xL, xR) = MiMCFeistel(xL, xR, 12200212977482648306758992405065921724409841940671166017620928947866825250857);
        (xL, xR) = MiMCFeistel(xL, xR, 10868453624107875516866146499877130701929063632959660262366632833504750028858);
        (xL, xR) = MiMCFeistel(xL, xR, 2016095394399807253596787752134573207202567875457560571095586743878953450738);
        (xL, xR) = MiMCFeistel(xL, xR, 21815578223768330433802113452339488275704145896544481092014911825656390567514);
        (xL, xR) = MiMCFeistel(xL, xR, 4923772847693564777744725640710197015181591950368494148029046443433103381621);
        (xL, xR) = MiMCFeistel(xL, xR, 1813584943682214789802230765734821149202472893379265320098816901270224589984);
        (xL, xR) = MiMCFeistel(xL, xR, 10810123816265612772922113403831964815724109728287572256602010709288980656498);
        (xL, xR) = MiMCFeistel(xL, xR, 1153669123397255702524721206511185557982017410156956216465120456256288427021);
        (xL, xR) = MiMCFeistel(xL, xR, 5007518659266430200134478928344522649876467369278722765097865662497773767152);
        (xL, xR) = MiMCFeistel(xL, xR, 2511432546938591792036639990606464315121646668029252285288323664350666551637);
        (xL, xR) = MiMCFeistel(xL, xR, 32883284540320451295484135704808083452381176816565850047310272290579727564);
        (xL, xR) = MiMCFeistel(xL, xR, 10484856914279112612610993418405543310546746652738541161791501150994088679557);
        (xL, xR) = MiMCFeistel(xL, xR, 2026733759645519472558796412979210009170379159866522399881566309631434814953);
        (xL, xR) = MiMCFeistel(xL, xR, 14731806221235869882801331463708736361296174006732553130708107037190460654379);
        (xL, xR) = MiMCFeistel(xL, xR, 14740327483193277147065845135561988641238516852487657117813536909482068950652);
        (xL, xR) = MiMCFeistel(xL, xR, 18787428285295558781869865751953016580493190547148386433580291216673009884554);
        (xL, xR) = MiMCFeistel(xL, xR, 3804047064713122820157099453648459188816376755739202017447862327783289895072);
        (xL, xR) = MiMCFeistel(xL, xR, 16709604795697901641948603019242067672006293290826991671766611326262532802914);
        (xL, xR) = MiMCFeistel(xL, xR, 11061717085931490100602849654034280576915102867237101935487893025907907250695);
        (xL, xR) = MiMCFeistel(xL, xR, 2821730726367472966906149684046356272806484545281639696873240305052362149654);
        (xL, xR) = MiMCFeistel(xL, xR, 17467794879902895769410571945152708684493991588672014763135370927880883292655);
        (xL, xR) = MiMCFeistel(xL, xR, 1571520786233540988201616650622796363168031165456869481368085474420849243232);
        (xL, xR) = MiMCFeistel(xL, xR, 10041051776251223165849354194892664881051125330236567356945669006147134614302);
        (xL, xR) = MiMCFeistel(xL, xR, 3981753758468103976812813304477670033098707002886030847251581853700311567551);
        (xL, xR) = MiMCFeistel(xL, xR, 4365864398105436789177703571412645548020537580493599380018290523813331678900);
        (xL, xR) = MiMCFeistel(xL, xR, 2391801327305361293476178683853802679507598622000359948432171562543560193350);
        (xL, xR) = MiMCFeistel(xL, xR, 214219368547551689972421167733597094823289857206402800635962137077096090722);
        (xL, xR) = MiMCFeistel(xL, xR, 18192064100315141084242006659317257023098826945893371479835220462302399655674);
        (xL, xR) = MiMCFeistel(xL, xR, 15487549757142039139328911515400805508248576685795694919457041092150651939253);
        (xL, xR) = MiMCFeistel(xL, xR, 10142447197759703415402259672441315777933858467700579946665223821199077641122);
        (xL, xR) = MiMCFeistel(xL, xR, 11246573086260753259993971254725613211193686683988426513880826148090811891866);
        (xL, xR) = MiMCFeistel(xL, xR, 6574066859860991369704567902211886840188702386542112593710271426704432301235);
        (xL, xR) = MiMCFeistel(xL, xR, 11311085442652291634822798307831431035776248927202286895207125867542470350078);
        (xL, xR) = MiMCFeistel(xL, xR, 20977948360215259915441258687649465618185769343138135384346964466965010873779);
        (xL, xR) = MiMCFeistel(xL, xR, 792781492853909872425531014397300057232399608769451037135936617996830018501);
        (xL, xR) = MiMCFeistel(xL, xR, 5027602491523497423798779154966735896562099398367163998686335127580757861872);
        (xL, xR) = MiMCFeistel(xL, xR, 14595204575654316237672764823862241845410365278802914304953002937313300553572);
        (xL, xR) = MiMCFeistel(xL, xR, 13973538843621261113924259058427434053808430378163734641175100160836376897004);
        (xL, xR) = MiMCFeistel(xL, xR, 16395063164993626722686882727042150241125309409717445381854913964674649318585);
        (xL, xR) = MiMCFeistel(xL, xR, 8465768840047024550750516678171433288207841931251654898809033371655109266663);
        (xL, xR) = MiMCFeistel(xL, xR, 21345603324471810861925019445720576814602636473739003852898308205213912255830);
        (xL, xR) = MiMCFeistel(xL, xR, 21171984405852590343970239018692870799717057961108910523876770029017785940991);
        (xL, xR) = MiMCFeistel(xL, xR, 10761027113757988230637066281488532903174559953630210849190212601991063767647);
        (xL, xR) = MiMCFeistel(xL, xR, 6678298831065390834922566306988418588227382406175769592902974103663687992230);
        (xL, xR) = MiMCFeistel(xL, xR, 4993662582188632374202316265508850988596880036291765531885657575099537176757);
        (xL, xR) = MiMCFeistel(xL, xR, 18364168158495573675698600238443218434246806358811328083953887470513967121206);
        (xL, xR) = MiMCFeistel(xL, xR, 3506345610354615013737144848471391553141006285964325596214723571988011984829);
        (xL, xR) = MiMCFeistel(xL, xR, 248732676202643792226973868626360612151424823368345645514532870586234380100);
        (xL, xR) = MiMCFeistel(xL, xR, 10090204501612803176317709245679152331057882187411777688746797044706063410969);
        (xL, xR) = MiMCFeistel(xL, xR, 21297149835078365363970699581821844234354988617890041296044775371855432973500);
        (xL, xR) = MiMCFeistel(xL, xR, 16729368143229828574342820060716366330476985824952922184463387490091156065099);
        (xL, xR) = MiMCFeistel(xL, xR, 4467191506765339364971058668792642195242197133011672559453028147641428433293);
        (xL, xR) = MiMCFeistel(xL, xR, 8677548159358013363291014307402600830078662555833653517843708051504582990832);
        (xL, xR) = MiMCFeistel(xL, xR, 1022951765127126818581466247360193856197472064872288389992480993218645055345);
        (xL, xR) = MiMCFeistel(xL, xR, 1888195070251580606973417065636430294417895423429240431595054184472931224452);
        (xL, xR) = MiMCFeistel(xL, xR, 4221265384902749246920810956363310125115516771964522748896154428740238579824);
        (xL, xR) = MiMCFeistel(xL, xR, 2825393571154632139467378429077438870179957021959813965940638905853993971879);
        (xL, xR) = MiMCFeistel(xL, xR, 19171031072692942278056619599721228021635671304612437350119663236604712493093);
        (xL, xR) = MiMCFeistel(xL, xR, 10780807212297131186617505517708903709488273075252405602261683478333331220733);
        (xL, xR) = MiMCFeistel(xL, xR, 18230936781133176044598070768084230333433368654744509969087239465125979720995);
        (xL, xR) = MiMCFeistel(xL, xR, 16901065971871379877929280081392692752968612240624985552337779093292740763381);
        (xL, xR) = MiMCFeistel(xL, xR, 146494141603558321291767829522948454429758543710648402457451799015963102253);
        (xL, xR) = MiMCFeistel(xL, xR, 2492729278659146790410698334997955258248120870028541691998279257260289595548);
        (xL, xR) = MiMCFeistel(xL, xR, 2204224910006646535594933495262085193210692406133533679934843341237521233504);
        (xL, xR) = MiMCFeistel(xL, xR, 16062117410185840274616925297332331018523844434907012275592638570193234893570);
        (xL, xR) = MiMCFeistel(xL, xR, 5894928453677122829055071981254202951712129328678534592916926069506935491729);
        (xL, xR) = MiMCFeistel(xL, xR, 4947482739415078212217504789923078546034438919537985740403824517728200332286);
        (xL, xR) = MiMCFeistel(xL, xR, 16143265650645676880461646123844627780378251900510645261875867423498913438066);
        (xL, xR) = MiMCFeistel(xL, xR, 397690828254561723549349897112473766901585444153303054845160673059519614409);
        (xL, xR) = MiMCFeistel(xL, xR, 11272653598912269895509621181205395118899451234151664604248382803490621227687);
        (xL, xR) = MiMCFeistel(xL, xR, 15566927854306879444693061574322104423426072650522411176731130806720753591030);
        (xL, xR) = MiMCFeistel(xL, xR, 14222898219492484180162096141564251903058269177856173968147960855133048449557);
        (xL, xR) = MiMCFeistel(xL, xR, 16690275395485630428127725067513114066329712673106153451801968992299636791385);
        (xL, xR) = MiMCFeistel(xL, xR, 3667030990325966886479548860429670833692690972701471494757671819017808678584);
        (xL, xR) = MiMCFeistel(xL, xR, 21280039024501430842616328642522421302481259067470872421086939673482530783142);
        (xL, xR) = MiMCFeistel(xL, xR, 15895485136902450169492923978042129726601461603404514670348703312850236146328);
        (xL, xR) = MiMCFeistel(xL, xR, 7733050956302327984762132317027414325566202380840692458138724610131603812560);
        (xL, xR) = MiMCFeistel(xL, xR, 438123800976401478772659663183448617575635636575786782566035096946820525816);
        (xL, xR) = MiMCFeistel(xL, xR, 814913922521637742587885320797606426167962526342166512693085292151314976633);
        (xL, xR) = MiMCFeistel(xL, xR, 12368712287081330853637674140264759478736012797026621876924395982504369598764);
        (xL, xR) = MiMCFeistel(xL, xR, 2494806857395134874309386694756263421445039103814920780777601708371037591569);
        (xL, xR) = MiMCFeistel(xL, xR, 16101132301514338989512946061786320637179843435886825102406248183507106312877);
        (xL, xR) = MiMCFeistel(xL, xR, 6252650284989960032925831409804233477770646333900692286731621844532438095656);
        (xL, xR) = MiMCFeistel(xL, xR, 9277135875276787021836189566799935097400042171346561246305113339462708861695);
        (xL, xR) = MiMCFeistel(xL, xR, 10493603554686607050979497281838644324893776154179810893893660722522945589063);
        (xL, xR) = MiMCFeistel(xL, xR, 8673089750662709235894359384294076697329948991010184356091130382437645649279);
        (xL, xR) = MiMCFeistel(xL, xR, 9558393272910366944245875920138649617479779893610128634419086981339060613250);
        (xL, xR) = MiMCFeistel(xL, xR, 19012287860122586147374214541764572282814469237161122489573881644994964647218);
        (xL, xR) = MiMCFeistel(xL, xR, 9783723818270121678386992630754842961728702994964214799008457449989291229500);
        (xL, xR) = MiMCFeistel(xL, xR, 15550788416669474113213749561488122552422887538676036667630838378023479382689);
        (xL, xR) = MiMCFeistel(xL, xR, 15016165746156232864069722572047169071786333815661109750860165034341572904221);
        (xL, xR) = MiMCFeistel(xL, xR, 6506225705710197163670556961299945987488979904603689017479840649664564978574);
        (xL, xR) = MiMCFeistel(xL, xR, 10796631184889302076168355684722130903785890709107732067446714470783437829037);
        (xL, xR) = MiMCFeistel(xL, xR, 19871836214837460419845806980869387567383718044439891735114283113359312279540);
        (xL, xR) = MiMCFeistel(xL, xR, 20871081766843466343749609089986071784031203517506781251203251608363835140622);
        (xL, xR) = MiMCFeistel(xL, xR, 5100105771517691442278432864090229416166996183792075307747582375962855820797);
        (xL, xR) = MiMCFeistel(xL, xR, 8777887112076272395250620301071581171386440850451972412060638225741125310886);
        (xL, xR) = MiMCFeistel(xL, xR, 5300440870136391278944213332144327695659161151625757537632832724102670898756);
        (xL, xR) = MiMCFeistel(xL, xR, 1205448543652932944633962232545707633928124666868453915721030884663332604536);
        (xL, xR) = MiMCFeistel(xL, xR, 5542499997310181530432302492142574333860449305424174466698068685590909336771);
        (xL, xR) = MiMCFeistel(xL, xR, 11028094245762332275225364962905938096659249161369092798505554939952525894293);
        (xL, xR) = MiMCFeistel(xL, xR, 19187314764836593118404597958543112407224947638377479622725713735224279297009);
        (xL, xR) = MiMCFeistel(xL, xR, 17047263688548829001253658727764731047114098556534482052135734487985276987385);
        (xL, xR) = MiMCFeistel(xL, xR, 19914849528178967155534624144358541535306360577227460456855821557421213606310);
        (xL, xR) = MiMCFeistel(xL, xR, 2929658084700714257515872921366736697080475676508114973627124569375444665664);
        (xL, xR) = MiMCFeistel(xL, xR, 15092262360719700162343163278648422751610766427236295023221516498310468956361);
        (xL, xR) = MiMCFeistel(xL, xR, 21578580340755653236050830649990190843552802306886938815497471545814130084980);
        (xL, xR) = MiMCFeistel(xL, xR, 1258781501221760320019859066036073675029057285507345332959539295621677296991);
        (xL, xR) = MiMCFeistel(xL, xR, 3819598418157732134449049289585680301176983019643974929528867686268702720163);
        (xL, xR) = MiMCFeistel(xL, xR, 8653175945487997845203439345797943132543211416447757110963967501177317426221);
        (xL, xR) = MiMCFeistel(xL, xR, 6614652990340435611114076169697104582524566019034036680161902142028967568142);
        (xL, xR) = MiMCFeistel(xL, xR, 19212515502973904821995111796203064175854996071497099383090983975618035391558);
        (xL, xR) = MiMCFeistel(xL, xR, 18664315914479294273286016871365663486061896605232511201418576829062292269769);
        (xL, xR) = MiMCFeistel(xL, xR, 11498264615058604317482574216318586415670903094838791165247179252175768794889);
        (xL, xR) = MiMCFeistel(xL, xR, 10814026414212439999107945133852431304483604215416531759535467355316227331774);
        (xL, xR) = MiMCFeistel(xL, xR, 17566185590731088197064706533119299946752127014428399631467913813769853431107);
        (xL, xR) = MiMCFeistel(xL, xR, 14016139747289624978792446847000951708158212463304817001882956166752906714332);
        (xL, xR) = MiMCFeistel(xL, xR, 8242601581342441750402731523736202888792436665415852106196418942315563860366);
        (xL, xR) = MiMCFeistel(xL, xR, 9244680976345080074252591214216060854998619670381671198295645618515047080988);
        (xL, xR) = MiMCFeistel(xL, xR, 12216779172735125538689875667307129262237123728082657485828359100719208190116);
        (xL, xR) = MiMCFeistel(xL, xR, 10702811721859145441471328511968332847175733707711670171718794132331147396634);
        (xL, xR) = MiMCFeistel(xL, xR, 6479667912792222539919362076122453947926362746906450079329453150607427372979);
        (xL, xR) = MiMCFeistel(xL, xR, 15117544653571553820496948522381772148324367479772362833334593000535648316185);
        (xL, xR) = MiMCFeistel(xL, xR, 6842203153996907264167856337497139692895299874139131328642472698663046726780);
        (xL, xR) = MiMCFeistel(xL, xR, 12732823292801537626009139514048596316076834307941224506504666470961250728055);
        (xL, xR) = MiMCFeistel(xL, xR, 6936272626871035740815028148058841877090860312517423346335878088297448888663);
        (xL, xR) = MiMCFeistel(xL, xR, 17297554111853491139852678417579991271009602631577069694853813331124433680030);
        (xL, xR) = MiMCFeistel(xL, xR, 16641596134749940573104316021365063031319260205559553673368334842484345864859);
        (xL, xR) = MiMCFeistel(xL, xR, 7400481189785154329569470986896455371037813715804007747228648863919991399081);
        (xL, xR) = MiMCFeistel(xL, xR, 2273205422216987330510475127669563545720586464429614439716564154166712854048);
        (xL, xR) = MiMCFeistel(xL, xR, 15162538063742142685306302282127534305212832649282186184583465569986719234456);
        (xL, xR) = MiMCFeistel(xL, xR, 5628039096440332922248578319648483863204530861778160259559031331287721255522);
        (xL, xR) = MiMCFeistel(xL, xR, 16085392195894691829567913404182676871326863890140775376809129785155092531260);
        (xL, xR) = MiMCFeistel(xL, xR, 14227467863135365427954093998621993651369686288941275436795622973781503444257);
        (xL, xR) = MiMCFeistel(xL, xR, 18224457394066545825553407391290108485121649197258948320896164404518684305122);
        (xL, xR) = MiMCFeistel(xL, xR, 274945154732293792784580363548970818611304339008964723447672490026510689427);
        (xL, xR) = MiMCFeistel(xL, xR, 11050822248291117548220126630860474473945266276626263036056336623671308219529);
        (xL, xR) = MiMCFeistel(xL, xR, 2119542016932434047340813757208803962484943912710204325088879681995922344971);

        t = xL;
        exp = mulmod(t, t, FIELD_SIZE);
        exp = mulmod(exp, exp, FIELD_SIZE);
        exp = mulmod(exp, t, FIELD_SIZE);
        xR = addmod(xR, exp, FIELD_SIZE);

        return (xL, xR);
    }

    function hashLeftRight(
        uint256 left,
        uint256 right
    ) internal pure returns (uint256) {
        uint256 R = left;
        uint256 C = 0;
        (R, C) = MiMCSponge(R, C);
        R = addmod(R, right, FIELD_SIZE);
        (R, C) = MiMCSponge(R, C);
        return R;
    }
}
