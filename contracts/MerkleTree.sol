// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MiMC} from "./MiMC.sol";

library MerkleTree {
    struct Info {
        uint256 levels;
        uint256 leafIndex;
        uint256 rootSize;
        uint256 rootIndex;
        mapping(uint256 => uint256) subTrees;
        mapping(uint256 => uint256) roots;
    }

    uint256 private constant MIN_LEVELS = 1;
    uint256 private constant MAX_LEVELS = 32;

    uint256 private constant MIN_ROOT_SIZE = 10;
    uint256 private constant MAX_ROOT_SIZE = 1000;

    function init(
        Info storage self,
        uint256 levels,
        uint256 rootSize
    ) internal {
        require(
            levels >= MIN_LEVELS && levels <= MAX_LEVELS,
            "Merkle tree levels must be [1, 32]"
        );
        require(
            rootSize >= MIN_ROOT_SIZE && rootSize <= MAX_ROOT_SIZE,
            "Merkle tree root size must be [10, 1000]"
        );

        self.levels = levels;
        self.leafIndex = 0;
        self.rootSize = rootSize;
        self.rootIndex = 0;
        for (uint256 i = 0; i <= levels; ++i) {
            self.subTrees[i] = _getZero(i);
        }
        self.roots[0] = _getZero(0);
    }

    function insertLeaf(
        Info storage self,
        uint256 leaf
    ) internal returns (uint256) {
        uint256 levels = self.levels;
        uint256 leafIndex = self.leafIndex;
        require(leafIndex != 2 ** levels, "Merkle tree is full");

        uint256 rootSize = self.rootSize;
        uint256 rootIndex = self.rootIndex;

        uint256 currentLeafIndex = leafIndex;
        uint256 currentLevelHash = leaf;

        uint256 left;
        uint256 right;

        for (uint256 i = 0; i < levels; ++i) {
            if (currentLeafIndex % 2 == 0) {
                left = currentLevelHash;
                right = _getZero(i);
                self.subTrees[i] = currentLevelHash;
            } else {
                left = self.subTrees[i];
                right = currentLevelHash;
            }
            currentLevelHash = MiMC.hashLeftRight(left, right);
            currentLeafIndex /= 2;
        }

        uint256 newRootIndex = (rootIndex + 1) % rootSize;
        self.rootIndex = newRootIndex;
        self.roots[newRootIndex] = currentLevelHash;

        self.leafIndex = leafIndex + 1;
        return leafIndex;
    }

    function isKnownRoot(
        Info storage self,
        uint256 root
    ) internal view returns (bool) {
        if (root == 0) {
            return false;
        }

        uint256 rootSize = self.rootSize;
        uint256 rootIndex = self.rootIndex;

        for (uint256 i = 0; i < rootSize; ++i) {
            uint256 index = (rootIndex + rootSize - i) % rootSize;
            if (self.roots[index] == root) return true;
        }

        return false;
    }

    function _getZero(uint256 index) private pure returns (uint256) {
        // keccak256("zkvault-classic") % BN254_FIELD_SIZE
        uint256[33] memory ZERO_VALUES = [
            10963288431021815655612693718125944876066744931256163158756426137396928311292,
            6357615818863919176020264648126569332163851638389872441705211734154351328255,
            15704653487405772150733817497079866972561533552516564758436325332962203010183,
            1519279217608881658495462190364738312845938220180280086709253153604640456135,
            3651817002997492395516445509734426326271971832927165020454773830264089873406,
            13495642043680099635941064151120306906417565510844429488948483082162864024758,
            10151953695909396438830423556150849194928107146499640074871478300969014808875,
            12434228873916768926154502234618321964924767322796210240973655527342039253983,
            15600154127222832581799124198021225906195647742677950029704413687564382471482,
            20460309702077370250918975147729246758210751018810573889748890118907722477283,
            9503525081932136036239041675523310740345964542741284729129130638644533779014,
            14116105045629559411499761920856517569954569518918004068388564098134004689989,
            20376310769886046581140461396559619172413457113990771710784550529712467869659,
            3741580495384111250208067699785625528326587362718443034676022550761964149570,
            19368135346513968986954698500133188659845852124597497445492323765602691450177,
            10980416033196623182262755853829950656774401053921171336172509317961944221198,
            12666228578405111527723809900495983677817181065706702080439038073455877054928,
            858033601089266546510945930333446990161217811881274902379931737402773936574,
            1786858821537399725407673394802404224366728713080901528266924319843253039654,
            6672864628799499426935707435141017141337064115870022512007852676114465722648,
            9886743587638211566787567834012461918819956600873594312479647768786539867130,
            17314464821365213704680202193705941125425095935617252932178798356587088895109,
            11185536906356264609989607352760019299463564746942710483150616337641689980501,
            7182988248827078805320826998513028699158613892571078804372496006816821791300,
            15973863816606997070537424346991119485630418395100353367059675239226908089989,
            10769858912046335656171018022404044915737627229022355160610112178506643724792,
            113381259370893640194666858464763565551933064330886556031311498680205991144,
            13046332442118387636127914623797492508102638449563640380594302215362427103314,
            14283009566265344297808290344555770544305140573251254942492404228841100564476,
            6014303150205970376722929764321597558169766226686391532138184927740070396266,
            13113305996979256349613814120742672104616634146846724593393139221635229284265,
            18468015206220462550333639802523765712223474066873422115934087387853493415545,
            4686199320161560985787885727003485506755933328141719080140411305451193032913
        ];
        return ZERO_VALUES[index];
    }
}
