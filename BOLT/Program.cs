using System;
using System.Text;

namespace BOLT {
    class Program {
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

        static byte[] transitions, touchVert, touchLeft, touchRight;

        static void Main(string[] args) {
            PrecomputeTables();
            TestTables();
            if (args.Length == 0) return;
            switch (args[0]) {
                case "save":
                    // TODO: Write tables
                    break;
                case "solve":
                    TestSolving(new Puzzle(TestPuzzle));
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
                        if (!thisHasBit && !touchingHasBit) filling = false;
                        if (filling) transitions[x] &= (byte) ~(1 << bit);
                    }
                    filling = false;
                    for (int bit = 0; bit < 8; bit++) {
                        bool thisHasBit = (curChunk & (1 << bit)) > 0;
                        bool touchingHasBit = (touchingOther & (1 << bit)) > 0;
                        if (thisHasBit && touchingHasBit) filling = true;
                        if (!thisHasBit && !touchingHasBit) filling = false;
                        if (filling) transitions[x] &= (byte) ~(1 << bit);
                    }
                }
                int changed = curChunk & ~transitions[x];
                touchVert[x] = (byte) (changed | (changed << 1) | (changed >> 1));
                if ((changed & 1) > 0) touchRight[x] = 0x80;
                if ((changed & 0x80) > 0) touchLeft[x] = 1;
            }
        }

        static void TestSolving(Puzzle Puzzle) {
            
            Console.WriteLine(Puzzle);
        }

        static void TestTables() {
            foreach (int test in new int[] { 0xDF_00, 0xDF_80, 0xDF_40, 0xFF_01, 0x83_02 }) {
                Console.WriteLine("Chunk:   " + Convert.ToString(test >> 8, 2).PadLeft(8, '0'));
                Console.WriteLine("Touches: " + Convert.ToString(test & 0xff, 2).PadLeft(8, '0'));
                Console.WriteLine("Result:  " + Convert.ToString(transitions[test], 2).PadLeft(8, '0'));
                Console.WriteLine("VCheck:  " + Convert.ToString(touchVert[test], 2).PadLeft(8, '0'));
                Console.WriteLine("LCheck:  " + Convert.ToString(touchLeft[test], 2).PadLeft(8, '0'));
                Console.WriteLine("RCheck:  " + Convert.ToString(touchRight[test], 2).PadLeft(8, '0'));
                Console.WriteLine();
            }
        }
    }
    class Puzzle {
        public int Width;
        public int Height;
        public char[] Map;
        public byte[] Bitmap;
        public Puzzle(string Text) {
            string[] lines = Text.Split("\r\n", StringSplitOptions.RemoveEmptyEntries);
            Height = lines.Length;
            Width = lines[0].Length;
            Map = new char[Width * Height];
            int bytesWidth = (Width % 8 == 0) ? (Width / 8) : (Width / 8) + 1;
            Bitmap = new byte[bytesWidth * Height];
            for (int y = 0; y < Height; y++) {
                for (int x = 0; x < Width; x++) {
                    Map[y * Width + x] = lines[y][x];
                    if (Map[y * Width + x] == '#') Bitmap[y * bytesWidth + x / 8] |= (byte) (1 << (7 - (x % 8)));
                }
            }
        }
        public override string ToString() {
            StringBuilder builder = new StringBuilder();
            for (int c = 0; c < Width * Height; c++) {
                if (c % Width == 0 && c > 0) builder.AppendLine();
                builder.Append(Map[c]);
            }
            return builder.ToString();
        }
    }
}
