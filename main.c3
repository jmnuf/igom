import std::io;
import std::math;

fn String string_from_cstr(char *cstr) {
   DString builder = dstring::temp();
   for (usz i = 0; ;++i) {
       char c = cstr[i];
       if (c == '\0') {
          break;
       }
       builder.append_char(c);
   }
   return builder.str_view();
}

enum SyllableType : int {
     CON_VOW,
     CON_CON_VOW,
     CON_VOW_CON,
     CON_VOW_VOW_CON,
     VOW_CON,
     VOW_VOW,
     VOW,
}

const char[5] VOWELS = {'a', 'e', 'i', 'o', 'u'};
const char[21] CONSONANTS = { 'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z' };

fn String generate_word(uint min_syllables, uint max_syllables) {
   DString builder = dstring::temp();
   int syllables_count = rand_in_range(min_syllables, max_syllables);
   for (usz i = 0; i < syllables_count; ++i) {
       SyllableType t = (SyllableType).from_ordinal(rand(SyllableType.len));
       switch(t) {
           case CON_VOW:
               builder.append_char(CONSONANTS[rand(CONSONANTS.len)]);
               builder.append_char(VOWELS[rand(VOWELS.len)]);
           case CON_CON_VOW:
               builder.append_char(CONSONANTS[rand(CONSONANTS.len)]);
               builder.append_char(CONSONANTS[rand(CONSONANTS.len)]);
               builder.append_char(VOWELS[rand(VOWELS.len)]);
           case CON_VOW_CON:
               builder.append_char(CONSONANTS[rand(CONSONANTS.len)]);
               builder.append_char(VOWELS[rand(VOWELS.len)]);
               builder.append_char(CONSONANTS[rand(CONSONANTS.len)]);
           case CON_VOW_VOW_CON:
               builder.append_char(CONSONANTS[rand(CONSONANTS.len)]);
               builder.append_char(VOWELS[rand(VOWELS.len)]);
               builder.append_char(VOWELS[rand(VOWELS.len)]);
               builder.append_char(CONSONANTS[rand(CONSONANTS.len)]);
           case VOW_CON:
               builder.append_char(VOWELS[rand(VOWELS.len)]);
               builder.append_char(CONSONANTS[rand(CONSONANTS.len)]);
           case VOW_VOW:
               builder.append_char(VOWELS[rand(VOWELS.len)]);
               builder.append_char(VOWELS[rand(VOWELS.len)]);
           case VOW:
               builder.append_char(VOWELS[rand(VOWELS.len)]);
           default:
               $$unreachable();
       }
   }
   return builder.str_view();
}

macro shift_c_arr(argc, argv) {
      *argc -= 1;
      char *arg = (*argv)[0];
      String s = string_from_cstr(arg);
      *argv += 1;
      return s;
}

fn uint to_uint_or(String x, uint def_val) {
    uint? usr_v = x.to_uint();
    if (catch err = usr_v) {
       io::eprintfn("[ERROR] Couldn't parse string (%s) as a uint: %s", x, err);
       io::printfn("[INFO] Defaulting value to %d", def_val);
       return def_val;
    }
    if (usr_v < 1) {
        io::eprintfn("[ERROR] Given count is too low, must be at least 1");
        io::printfn("[INFO] Defaulting value to %d", def_val);
        return def_val;
    }
    return usr_v;
}

fn void usage(String program_name) {
    io::printfn("Usage: %s [-c <number>]", program_name);
    io::printfn("     -w <max-syllables>   ---  Generate <number> words");
    io::printfn("     -s <max-syllables>   ---  Max number of \"syllables\" to use");
    io::printfn("     -s <min>..<max>      ---  Range of min..max \"syllables\" to use");
    io::printfn("     -h                   ---  Display this message");
}

fn int main(int argc, char **argv) {
   String program_name = shift_c_arr(&argc, &argv);

   uint words_count = 5;
	 uint min_syllables = 1;
	 uint max_syllables = 4;
   while (argc > 0) {
       String arg = shift_c_arr(&argc, &argv);
       if (arg == "-w") {
           if (argc == 0) {
               io::eprintn("Missing number argument for words count flag");
               usage(program_name);
               return 1;
           }
           // Attempt to parse count
           String n = shift_c_arr(&argc, &argv);
           words_count = to_uint_or(n, words_count);
					 continue;
       }
       if (arg == "-s") {
           if (argc == 0) {
               io::eprintn("Missing number argument for max syllables flag");
               usage(program_name);
               return 1;
           }
           // Attempt to parse count
           String n = shift_c_arr(&argc, &argv);
           String[] range_str = n.tsplit("..");
					 if (range_str.len == 0) {
               io::eprintn("Missing number argument for max syllables flag");
               usage(program_name);
               return 1;
					 }
					 if (range_str.len == 1) {
               max_syllables = to_uint_or(range_str[0], max_syllables);
					 } else {
					     min_syllables = to_uint_or(range_str[0], min_syllables);
							 if (min_syllables < 1) {
							     io::eprintn("Minimum set too low, resetting it to 1");
									 min_syllables = 1;
							 }
               max_syllables = to_uint_or(range_str[1], max_syllables);
					 }
					 continue;
       }
       if (arg == "--help" || arg == "-h") {
           usage(program_name);
           return 0;
       }
       io::eprintfn("Unknown flag/command: %s", arg);
       usage(program_name);
       return 1;
   }
   
   // io::printfn("Generating %d words...", words_count);

   for (usz i = 0; i < words_count; ++i) {
       String word = generate_word(min_syllables, max_syllables);
       io::printf(" %s", word);
       if (i > 0 && (i + 1)%2 == 0) {
          io::print("\n");
       }
   }
   io::print("\n");
   return 0;
}

