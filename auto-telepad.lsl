// Typhaine Artez 2019
// Auto configured region teleports network
// Typhaine Artez (@sacrarium24.ru) - 2019
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/

integer NETCHAN = -423175;
integer UPDATES = 120;
integer OUTDATED = 600;

list pads;
string location;
string anim;
integer sndmenu;
integer sndtp;

key who = NULL_KEY;
integer menuchan;
integer menupg;

announce(key id) {
    string msg = llDumpList2String([location, llGetPos(), llGetRot()], ";");
    if (NULL_KEY == id) llRegionSay(NETCHAN, msg);
    else llRegionSayTo(id, NETCHAN, msg);
}

menu() {
    list btns;
    integer num = llGetListLength(pads) / 4;
    integer start = 0;
    integer end = num - 1;
    if (num > 11) {
        start = menupg * 9;
        end = (menupg + 1) * 9 - 1;
        if (end >= num) end = num - 1;
    }
    integer i;
    for (i = start; i <= end; ++i) {
        if ("" != llList2String(pads, i*4)) btns += llList2String(pads, i*4);
    }
    while (llGetListLength(btns) % 3) btns += " ";
    if (num > 12) {
        btns += [
            llList2String([" ", "◀ PAGE"], (menupg > 0)),
            "CANCEL",
            llList2String([" ", "PAGE ▶"], (end < num - 1))
        ];
    }
    else {
        num = llGetListLength(btns);
        if (num % 3) {
            while (llGetListLength(btns) % 3) btns += " ";
        }
        else {
            btns += [ " ", " ", " " ];
        }
        num = llGetListLength(btns) - 1;
        btns = llListReplaceList(btns, ["CANCEL"], num, num);
    }

    llDialog(who, "\nPlease select your destination in the following list",
        llList2List(btns,9,11)+llList2List(btns,6,8)+llList2List(btns,3,5)+llList2List(btns,0,2),
        menuchan);
}

unsit() {
    key av = sitter();
    if (NULL_KEY != av) {
        if (anim) llStopAnimation(anim);
        llUnSit(av);
        who = NULL_KEY;
    }
}

key sitter() {
    key av = llGetLinkKey(llGetNumberOfPrims());
    if (ZERO_VECTOR != llGetAgentSize(av)) return av;
    return NULL_KEY;
}

config(integer again) {
    string txt = "\nSet a name for the location of this telepad." +
        "\nThat will appear on the menu of other telepads.";
    if (again) txt = "\nInvalid empty location name!\n" + txt;
    llTextBox(llGetOwner(), txt, menuchan);
}

default {
    on_rez(integer p) {
        llResetScript();
    }
    state_entry() {
        unsit();

        menuchan = (integer)("0x" + llGetSubString(llGetKey(), 0, 7));
        location = llGetObjectDesc();
        if (!location) {
            // not configured, setup!
            state setup;
        }
        llSitTarget(<0.0, 0.0, 1.0>, ZERO_ROTATION);
        llSetClickAction(CLICK_ACTION_SIT);

        llListen(NETCHAN, "", "", "");
        llRegionSay(NETCHAN, "ping");
        announce(NULL_KEY);
        llSetTimerEvent(UPDATES);
        llListen(menuchan, "", "", "");
        if (llGetInventoryType("menu") == INVENTORY_SOUND) {
            sndmenu = TRUE;
            llPreloadSound("menu");
        }
        if (llGetInventoryType("tp") == INVENTORY_SOUND) {
            sndtp = TRUE;
            llPreloadSound("tp");
        }
    }
    listen(integer channel, string name, key id, string msg) {
        if (NETCHAN == channel) {
            list l = llParseString2List(msg, [";"], []);
            if ("ping" == llList2String(l, 0)) announce(id);
            else {
                if (3 != llGetListLength(l)) return;

                name = llList2String(l, 0);
                vector pos = (vector)llList2String(l, 1);
                rotation rot = (rotation)llList2String(l, 2);
                l = [name, pos, rot, llGetUnixTime() ];
                integer i = llListFindList(pads, [name]);
                if (~i) pads = llListReplaceList(pads, l, i, i+3);
                else {
                    llOwnerSay(location + ": added " + name);
                    pads += l;
                }
            }
        }
        else if (menuchan != 0 && menuchan == channel && id == who) {
            if ("◀ PAGE" == msg) {
                --menupg;
            }
            else if ("PAGE ▶" == msg) {
                ++menupg;
            }
            else if (" " != msg) {
                integer i = llListFindList(pads, [msg]);
                if (~i) {
                    vector sz = llGetAgentSize(who);
                    sz.x = 0;
                    sz.y = 0;
                    vector return2 = llGetPos();
                    rotation rot2 = llGetRot();
                    if (sndtp) llPlaySound("tp", 1.0);
                    llSetRegionPos(llList2Vector(pads, i+1)+sz);
                    llSetRot(llList2Rot(pads, i+2));
                    llSleep(0.5);
                    unsit();
                    llSetRegionPos(return2);
                    llSetRot(rot2);
                }
                unsit();
                return;
            }
            menu();
        }
    }
    timer() {
        // check if some are not outdated
        integer n = llGetListLength(pads) - 4;
        integer now = llGetUnixTime();
        for (; -1 < n; n -= 4) {
            if (OUTDATED < now - llList2Integer(pads, n+3)) {
                if (4 == llGetListLength(pads)) pads = [];
                else pads = llDeleteSubList(pads, n, n+3);
            }
        }
        announce(NULL_KEY);
    }
    changed(integer c) {
        if (CHANGED_LINK & c) {
            key a = llAvatarOnSitTarget();
            if (NULL_KEY != a) {
                if ([] == pads) {
                    llRegionSayTo(a, 0, "Sorry, this telepad is not connected to other pads.");
                    unsit();
                }
                else {
                    who = a;
                    llRequestPermissions(who, PERMISSION_TRIGGER_ANIMATION);
                }
            }
            else {
                unsit();
            }
        }
    }
    run_time_permissions(integer p) {
        if (PERMISSION_TRIGGER_ANIMATION & p) {
            llStopAnimation("sit");
            anim = llGetInventoryName(INVENTORY_ANIMATION, 0);
            if (anim) llStartAnimation(anim);
            if (sndmenu) llPlaySound("menu", 1.0);
            menupg = 0;
            menu();
        }
    }
    touch_start(integer n) {
        if (llDetectedKey(0) == who) menu();
    }
}

state setup {
    on_rez(integer p) {
        llResetScript();
    }
    state_entry() {
        llSetClickAction(CLICK_ACTION_TOUCH);
        llSitTarget(ZERO_VECTOR, ZERO_ROTATION);
        llListen(menuchan, "", llGetOwner(), "");
        config(FALSE);
    }
    touch_start(integer n) {
        if (llDetectedKey(0) == llGetOwner()) config(FALSE);
    }
    listen(integer channel, string name, key id, string msg) {
        if (msg != "") {
            llSetObjectDesc(msg);
            llResetScript();
        }
        config(TRUE);
    }
}
