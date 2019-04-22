using System;
using System.Text;
using System.IO;

namespace BOLT {
    class Program {
        const string DebugPuzzle = @"
________ _____
________ _____
________ ___##
________ __###
____##__ __##_
____###_ __#_#
_#___### ##_#_
####___# _##__
";
        const string TestPuzzle = @"
________________####_________________
______#_________######_______________
_____#_##______###___##____________##
____##_##_______##____#___________###
____##___#__________________##____##_
____##_##___________###_____###___#_#
___#__#____________###___#___#####_#_
___#_____###__#_#_#_##__####___#_##__
_##__#######__#####_____#__#_________
#___###__####_##______###__#__####___
##___#________##_###_#_______#####___
#____________##__###_#_###____#_##___
##__________#___###__#_###____###____
#_____________#####_##_________##__##
##__________#____#__##_##_______#__#_
#___________####____##_##______###__#
________#____####______###____####_#_
_####__##____###_##___###_#__##__#_#_
#____#_#_#___####______#_#_#_______##
____###__#____#_#_____##__##____#####
___####_#______________#_##____##__#_
___#######__###________##______#_____
_____##_#___####_____#___________###_
__________##__##_____##_______#####_#
__________#_####______#_______####_##
___________#####_#_##_#___#___###___#
______________##_####_#_####___#__#_#
_________###______#####__#####___##__
__________###_###_###____####___####_
___________#__##__________##_____###_
________##___#____##_##__#________#__
_______#####_##_##_##_##__#________##
_______#####_##_##__#_#_#__#_______##
_______####_____#___#__##__##____###_
_______#_#___##______###__###____###_
______####_#######____#____#__##_____
_________#_########__________##_####_";

        const string AnotherPuzzle = @"
_____________________####__##_#__
____________________####___####__
_______________#____##___#_###___
______________####____#_##__##___
_______________####___#__##_##___
_____________##__#_#__##_##____##
________________#####____#__##__#
______#___________##___##_#_###__
_____#_#####_________#__##______#
______##_##_###_____#_________###
_____________#######__#_##____###
_________________##__#___#____###
_____________###_____#_##______#_
______##_____###___##__###_______
____#_#_##__####_______####______
___##____##_####_###___##_#____#_
##_###__###___#__##_#____#___####
##_#_##_##_##____#__###_____#####
##__###__#####___#__#__###_______
#__##_____________#_____###_###__
_#____##__________#__##__________
__#___###________#__###__###_##__
___#_###___________#____####_####
__##_####___________#_#___##___##
___#_###___________#__##_____#_##
____________________#_###__###___
___###_____________#__###_##_###_
___####____________##__#__##____#
___###_#__________####______#_#__
____##__#______________#______###
_____#_#____________###_##__#####
______#___________###_####_###_##";

        static byte[] transitions, touchVert, touchLeft, touchRight;
        static uint[] maskA, maskB;

        static void Main(string[] args) {
            PrecomputeTables();
            TestTables();
            if (args.Length == 0) return;
            switch (args[0]) {
                case "save":
                    string result = WriteTables();
                    if (args.Length >= 2) {
                        File.WriteAllText(args[1], result);
                    } else {
                        Console.WriteLine(result);
                    }
                    break;
                case "solve":
                    Puzzle puzzle = new Puzzle(DebugPuzzle);
                    TestSolving(puzzle);
                    break;
            }
        }

        static void PrecomputeTables() {
            transitions = new byte[256 * 256];
            touchVert = new byte[transitions.Length];
            touchLeft = new byte[transitions.Length];
            touchRight = new byte[transitions.Length];
            for (int x = 0; x < transitions.Length; x++) {
                int curChunk = x >> 8;
                int touchingOther = x & 0xff;
                transitions[x] = (byte) curChunk;
                if (touchingOther == 0) {
                    // Just starting a fill - take the first contiguous run
                    bool filling = false;
                    for (int bit = 7; bit >= 0; bit--) {
                        bool hasBit = (curChunk & (1 << bit)) > 0;
                        if (filling && !hasBit) break;
                        if (hasBit) filling = true;
                        if (filling) transitions[x] &= (byte) ~(1 << bit);
                    }
                } else {
                    // Continuing a fill - only fill what's touching something from another chunk
                    bool filling = false;
                    for (int bit = 7; bit >= 0; bit--) {
                        bool thisHasBit = (curChunk & (1 << bit)) > 0;
                        bool touchingHasBit = (touchingOther & (1 << bit)) > 0;
                        if (thisHasBit && touchingHasBit) filling = true;
                        if (!thisHasBit) filling = false;
                        if (filling) transitions[x] &= (byte) ~(1 << bit);
                    }
                    filling = false;
                    for (int bit = 0; bit < 8; bit++) {
                        bool thisHasBit = (curChunk & (1 << bit)) > 0;
                        bool touchingHasBit = (touchingOther & (1 << bit)) > 0;
                        if (thisHasBit && touchingHasBit) filling = true;
                        if (!thisHasBit) filling = false;
                        if (filling) transitions[x] &= (byte) ~(1 << bit);
                    }
                }
                int changed = curChunk & ~transitions[x];
                touchVert[x] = (byte) (changed | (changed << 1) | (changed >> 1));
                if ((changed & 1) > 0) touchRight[x] = 0x80;
                if ((changed & 0x80) > 0) touchLeft[x] = 1;
            }

            maskA = new uint[256];
            maskB = new uint[maskA.Length];
            for (int x = 0; x < maskA.Length; x++) {
                if ((x & 1) > 0) maskB[x] |= 0xFF000000;
                if ((x & 2) > 0) maskB[x] |= 0x00FF0000;
                if ((x & 4) > 0) maskB[x] |= 0x0000FF00;
                if ((x & 8) > 0) maskB[x] |= 0x000000FF;
                if ((x & 16) > 0) maskA[x] |= 0xFF000000;
                if ((x & 32) > 0) maskA[x] |= 0x00FF0000;
                if ((x & 64) > 0) maskA[x] |= 0x0000FF00;
                if ((x & 128) > 0) maskA[x] |= 0x000000FF;
            }
        }

        static void TestSolving(Puzzle Puzzle) {
            void StoreWord(byte[] Array, int Address, int Value) {
                byte[] leBytes = BitConverter.GetBytes(Value);
                for (int i = 0; i < 4; i++) {
                    Array[Address + i] = leBytes[i];
                }
            }
            int[] queue = new int[400];
            int qStart, qEnd;
            void Enqueue(int Position) {
                queue[qEnd] = Position;
                qEnd++;
            }
            byte scanStart = 0; // How many starting chunks are now empty and can be skipped
            char marker = 'A';
            while (scanStart < Puzzle.Bitmap.Length) {
                byte[] contact = new byte[Puzzle.BytesWidth * Puzzle.Height];
                byte chunk = Puzzle.Bitmap[scanStart];
                if (chunk == 0) {
                    scanStart++;
                    continue;
                }
                qStart = 0;
                qEnd = 1;
                queue[0] = scanStart;
                for (; qStart != qEnd; qStart++) {
                    int position = queue[qStart];
                    chunk = Puzzle.Bitmap[position];
                    if (chunk == 0) continue;
                    int touching = contact[position];
                    int lookupId = chunk << 8 | touching;
                    Puzzle.Bitmap[position] = transitions[lookupId];
                    int changed = chunk & ~Puzzle.Bitmap[position];
                    if (changed == 0) continue;
                    int mapPos = (position % Puzzle.BytesWidth) * 8 + (position / Puzzle.BytesWidth) * Puzzle.Width;
                    while (changed != 0) {
                        if (changed >= 0x80) {
                            if (Puzzle.Map[mapPos] != (byte) '#') throw new Exception("Tried to fill a bad spot");
                            Puzzle.Map[mapPos] = (byte) marker;
                        }
                        changed = (changed << 1) & 0xff;
                        mapPos++;
                    }
                    int upPos = position - Puzzle.BytesWidth;
                    if (upPos >= 0 && Puzzle.Bitmap[upPos] != 0) {
                        contact[upPos] |= touchVert[lookupId];
                        Enqueue(upPos);
                    }
                    int downPos = position + Puzzle.BytesWidth;
                    if (downPos < Puzzle.Bitmap.Length && Puzzle.Bitmap[downPos] != 0) {
                        contact[downPos] |= touchVert[lookupId];
                        Enqueue(downPos);
                    }
                    if (position % Puzzle.BytesWidth != 0 && touchLeft[lookupId] != 0) {
                        if (Puzzle.Bitmap[position - 1] != 0) {
                            contact[position - 1] |= touchLeft[lookupId];
                            Enqueue(position - 1);
                        }
                        if (downPos < Puzzle.Bitmap.Length && Puzzle.Bitmap[downPos - 1] != 0) {
                            contact[downPos - 1] |= touchLeft[lookupId];
                            Enqueue(downPos - 1);
                        }
                        if (upPos >= 0 && Puzzle.Bitmap[upPos - 1] != 0) {
                            contact[upPos - 1] |= touchLeft[lookupId];
                            Enqueue(upPos - 1);
                        }
                    }
                    if ((position + 1) % Puzzle.BytesWidth != 0 && touchRight[lookupId] != 0) {
                        if (Puzzle.Bitmap[position + 1] != 0) {
                            contact[position + 1] |= touchRight[lookupId];
                            Enqueue(position + 1);
                        }
                        if (downPos < Puzzle.Bitmap.Length && Puzzle.Bitmap[downPos + 1] != 0) {
                            contact[downPos + 1] |= touchRight[lookupId];
                            Enqueue(downPos + 1);
                        }
                        if (upPos >= 0 && Puzzle.Bitmap[upPos + 1] != 0) {
                            contact[upPos + 1] |= touchRight[lookupId];
                            Enqueue(upPos + 1);
                        }
                    }
                }
                marker++;
            }
            Console.WriteLine(Puzzle);
        }

        static void TestTables() {
            foreach (int test in new int[] { 0xDF_00, 0xDF_80, 0xDF_40, 0xFF_01, 0x83_02, 0xC6_FC, 0xF1_0F }) {
                Console.WriteLine("Chunk:   " + Convert.ToString(test >> 8, 2).PadLeft(8, '0'));
                Console.WriteLine("Touches: " + Convert.ToString(test & 0xff, 2).PadLeft(8, '0'));
                Console.WriteLine("Result:  " + Convert.ToString(transitions[test], 2).PadLeft(8, '0'));
                Console.WriteLine("VCheck:  " + Convert.ToString(touchVert[test], 2).PadLeft(8, '0'));
                Console.WriteLine("LCheck:  " + Convert.ToString(touchLeft[test], 2).PadLeft(8, '0'));
                Console.WriteLine("RCheck:  " + Convert.ToString(touchRight[test], 2).PadLeft(8, '0'));
                Console.WriteLine();
            }
        }

        static string WriteTables() {
            StringBuilder result = new StringBuilder();
            void WriteArray(byte[] Array) {
                int onThisLine = 0;
                foreach (byte b in Array) {
                    if (onThisLine == 2048) {
                        result.AppendLine();
                        result.Append("\t\t\t.byte ");
                        onThisLine = 0;
                    }
                    result.Append(b);
                    result.Append(' ');
                    onThisLine++;
                }
                result.AppendLine();
            }
            result.Append("puzzle_transition:\t.byte ");
            WriteArray(transitions);
            result.Append("puzzle_touch_vert:\t.byte ");
            WriteArray(touchVert);
            result.Append("puzzle_touch_left:\t.byte ");
            WriteArray(touchLeft);
            result.Append("puzzle_touch_right:\t.byte ");
            WriteArray(touchRight);
            return result.ToString();
        }
    }
    class Puzzle {
        public int Width;
        public int BytesWidth;
        public int Height;
        public byte[] Map;
        public byte[] Bitmap;
        public Puzzle(string Text) {
            string[] lines = Text.Replace(" ", "").Split("\r\n", StringSplitOptions.RemoveEmptyEntries);
            Height = lines.Length;
            Width = lines[0].Length;
            Map = new byte[Width * Height];
            BytesWidth = (Width % 8 == 0) ? (Width / 8) : (Width / 8) + 1;
            Bitmap = new byte[BytesWidth * Height];
            for (int y = 0; y < Height; y++) {
                for (int x = 0; x < Width; x++) {
                    Map[y * Width + x] = (byte) lines[y][x];
                    if (Map[y * Width + x] == (byte) '#') Bitmap[y * BytesWidth + x / 8] |= (byte) (1 << (7 - (x % 8)));
                }
            }
        }
        public override string ToString() {
            StringBuilder builder = new StringBuilder();
            for (int c = 0; c < Width * Height; c++) {
                if (c % Width == 0 && c > 0) builder.AppendLine();
                builder.Append((char) Map[c]);
            }
            return builder.ToString();
        }
    }
}
