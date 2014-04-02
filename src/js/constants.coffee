angular.module('Courses.constants', [])
.value(
  'DEPARTMENTS',
  ["ACLB", "ACTU", "AFSB", "AHAR", "AMSB", "AMST", "ANAT", "ANCB", "ANCS", "ANTB", "ANTH", "APAM", "ARAC", "ARAF", "ARCB", "ARCH", "ARCY", "ARHB", "ASMB", "ASTR", "BCHM", "BIOB", "BIOS", "BIST", "BUSC", "BUSI", "CBME", "CEAC", "CEEM", "CHEM", "CHMB", "CLAS", "CLMS", "CLSB", "CMBS", "CMPL", "COCI", "COLB", "COLM", "COMM", "COMS", "CSER", "CSPB", "DANB", "DESC", "EAEE", "EALC", "ECHB", "ECOB", "ECON", "EDNB", "EEEB", "EESC", "ELEN", "ENCL", "ENGB", "ENGI", "ENSB", "FFPS", "FILB", "FILM", "FRNB", "FRRP", "FUND", "FYSB", "GEND", "GERL", "GRMB", "HINC", "HIST", "HPSC", "HRSB", "HSTB", "HUMR", "ICLS", "IEOR", "INAF", "IRCE", "ITAL", "ITLB", "JAPN", "JAZZ", "JOUC", "LAND", "LAWC", "LAWS", "LING", "LRC", "MATH", "MECE", "MEDI", "MELC", "MIAC", "MICR", "MPAC", "MRSB", "MSAE", "MUSI", "NEUB", "NUTR", "PATH", "PEDB", "PHAR", "PHED", "PHIL", "PHLB", "PHPH", "PHYB", "PHYG", "PHYS", "PLSB", "POLS", "PSYB", "PSYC", "PUHS", "QMSS", "RELB", "RELI", "SCPB", "SCTS", "SCWS", "SIPX", "SLAL", "SOCB", "SOCI", "SOCW", "SOSC", "SPNB", "SPPO", "STAT", "SUDV", "TCOS", "THEA", "THEB", "UBST", "UNSC", "URBS", "URPL", "VIAR", "WMST", "WPGS", "WSTB"]
)
.value(
  'CONFIG',
    COURSES_API: 'db.adicu.com/api/'
    DATA_API: 'http://data.adicu.com/courses/v2/'
    API_TOKEN: '51ffc99d0b18dc0002859b8d'
    ES_API: 'http://db.data.adicu.com:9200'
)
.value(
  'CourseState',
    VISIBLE: 1                      # Normal view
    EXCLUSIVE_VISIBLE: 2            # Hide all other Courses
)
.value(
  'Colors',
  [{"color": "red"},
   {"color": "orange"},
   {"color": "yellow"},
   {"color": "green"},
   {"color": "forest"},
   {"color": "blue"},
   {"color": "true"},
   {"color": "midnight"},
   {"color": "purple"},
   {"color": "gray"}]
)
.value(
  'Semesters',
   ['20141', '20133']
)
.value(
  'SemesterDates',
  START_CURRENT:"01/20/2014"
  END_CURRENT:"05/21/2014"
  START_LAST:"09/2/2014"
  END_LAST:"12/20/2014"
)

