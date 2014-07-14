if (!this.Co) {
  Co = {};
}

Co.constants = {
  departments: ["ACLB", "ACTU", "AFSB", "AHAR", "AMSB", "AMST", "ANAT", "ANCB", "ANCS", "ANTB", "ANTH", "APAM", "ARAC", "ARAF", "ARCB", "ARCH", "ARCY", "ARHB", "ASMB", "ASTR", "BCHM", "BIOB", "BIOS", "BIST", "BUSC", "BUSI", "CBME", "CEAC", "CEEM", "CHEM", "CHMB", "CLAS", "CLMS", "CLSB", "CMBS", "CMPL", "COCI", "COLB", "COLM", "COMM", "COMS", "CSER", "CSPB", "DANB", "DESC", "EAEE", "EALC", "ECHB", "ECOB", "ECON", "EDNB", "EEEB", "EESC", "ELEN", "ENCL", "ENGB", "ENGI", "ENSB", "FFPS", "FILB", "FILM", "FRNB", "FRRP", "FUND", "FYSB", "GEND", "GERL", "GRMB", "HINC", "HIST", "HPSC", "HRSB", "HSTB", "HUMR", "ICLS", "IEOR", "INAF", "IRCE", "ITAL", "ITLB", "JAPN", "JAZZ", "JOUC", "LAND", "LAWC", "LAWS", "LING", "LRC", "MATH", "MECE", "MEDI", "MELC", "MIAC", "MICR", "MPAC", "MRSB", "MSAE", "MUSI", "NEUB", "NUTR", "PATH", "PEDB", "PHAR", "PHED", "PHIL", "PHLB", "PHPH", "PHYB", "PHYG", "PHYS", "PLSB", "POLS", "PSYB", "PSYC", "PUHS", "QMSS", "RELB", "RELI", "SCPB", "SCTS", "SCWS", "SIPX", "SLAL", "SOCB", "SOCI", "SOCW", "SOSC", "SPNB", "SPPO", "STAT", "SUDV", "TCOS", "THEA", "THEB", "UBST", "UNSC", "URBS", "URPL", "VIAR", "WMST", "WPGS", "WSTB"],

  config: {
    COURSES_API: 'db.adicu.com/api/',
    DATA_API: 'http://data.adicu.com/courses/v2/',
    API_TOKEN: '51ffc99d0b18dc0002859b8d'
  },

  courseState: {
    VISIBLE: 1,
    EXCLUSIVE_VISIBLE: 2
  },

  colors: ['red', 'orange', 'yellow', 'green', 'forest', 'blue', 'midnight', 'purple', 'gray'],

  semesters: ['20143', '20141'],

  semesterDates: {
    20143: {
      start: moment('09/2/2014', 'MM-DD-YYYY'),
      end: moment('12/9/2014', 'MM-DD-YYYY')
    },
    20141: {
      start: moment('01/20/2014', 'MM-DD-YYYY'),
      end: moment('05/21/2014', 'MM-DD-YYYY')
    }
  }
};
