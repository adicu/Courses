import sys
import argparse
import os
import time
import collections
import json

import pymongo

course_schema = [
    ("Course", "varchar(32) primary key"),
    ("CourseFull", "varchar(32)"),
    ("PrefixName", "varchar(32)"),
    ("DivisionCode", "varchar(32)"),
    ("DivisionName", "varchar(64)"),
    ("SchoolCode", "varchar(32)"),
    ("SchoolName", "varchar(64)"),
    ("DepartmentCode", "varchar(32)"),
    ("DepartmentName", "varchar(64)"),
    ("EnrollmentStatus", "varchar(32)"),
    ("NumFixedUnits", "int"),
    ("MinUnits", "int"),
    ("MaxUnits", "int"),
    ("CourseTitle", "varchar(64)"),
    ("CourseSubtitle", "varchar(64)"),
    ("Approval", "varchar(32)"),
    ("BulletinFlags", "varchar(32)"),
    ("ClassNotes", "varchar(64)"),
    ("PrefixLongname", "varchar(32)"),
    ("Description", "text")
]

section_schema = [
    ("CallNumber", "int"),
    ("SectionFull", "varchar(32)"),
    ("Course", "varchar(32) references courses_v2_t(course)"),
    ("Term", "varchar(32)"),
    ("NumEnrolled", "int"),
    ("MaxSize", "int"),
    ("TypeCode", "varchar(32)"),
    ("TypeName", "varchar(32)")
]

# these are given to us in a weird format and need to be massaged a little
special_fields = [
    'MeetsOn1',
    'StartTime1',
    'EndTime1',
    'Building1',
    'Room1',
    'MeetsOn2',
    'StartTime2',
    'EndTime2',
    'Building2',
    'Room2',
    'MeetsOn3',
    'StartTime3',
    'EndTime3',
    'Building3',
    'Room3',
    'MeetsOn4',
    'StartTime4',
    'EndTime4',
    'Building4',
    'Room4',
    'MeetsOn5',
    'StartTime5',
    'EndTime5',
    'Building5',
    'Room5',
    'MeetsOn6',
    'StartTime6',
    'EndTime6',
    'Building6',
    'Room6',
    'ExamMeetsOn',
    'ExamStartTime',
    'ExamEndTime',
    'ExamBuilding',
    'ExamRoom',
    'Description',
    'Course',
    'CourseFull',
    'SectionFull',
    'Meets1',
    'Meets2',
    'Meets3',
    'Meets4',
    'Meets5',
    'Meets6',
    "Instructor1Name",
    "Instructor2Name",
    "Instructor3Name",
    "Instructor4Name"
]
# format for meeting string (ex. "TR     03:00P-05:10PPUP PUPIN LABORA1332")
# these tuples are of the form (field, type, start_char, end_char)
MeetsTuple = collections.namedtuple('MeetsTuple',
    ['field', 'type', 'start_char', 'end_char']
)
meets_format = [
    ('MeetsOn', 'varchar(32)', 0, 7),
    ('StartTime', 'time', 7, 13),
    ('EndTime', 'time', 14, 20),
    ('Building', 'varchar(32)', 24, 36),
    ('Room', 'varchar(32)', 36, 42)
]
meets_format = [MeetsTuple._make(x) for x in meets_format]

def _format_course(course):
    return course[:4] + course[8] + course[4:8]

def _special_treatment_course(doc):
    pairs = []
    pairs.append(('Course', doc['Course'][:8]))
    pairs.append(('CourseFull', _format_course(doc['Course'])))

    return pairs

def _special_treatment_section(doc):
    num_meets = 6
    num_instructors = 4

    dict_pairs = {}
    for i in range(1, 1 + num_meets):
        meets = doc['Meets' + str(i)]
        for item in meets_format:
            if dict_pairs.get(item.field) is None:
                dict_pairs[item.field] = []
            value = meets[item.start_char:item.end_char].strip()
            if value:
                dict_pairs[item.field].append(_typify(value, item.type))

    dict_pairs['instructors'] = []
    for i in range(1, 1 + num_instructors):
        instructor = doc.get(("Instructor%sName"% i), '')
        if len(instructor) == 0:
            continue
        dict_pairs['instructors'].append(instructor)

    pairs = dict_pairs.items()
    pairs.append(('CourseFull', _format_course(doc['Course'])))
    pairs.append(('SectionFull', doc['Term'] + doc['Course']))
    return pairs

def drop_table(mongo_uri):
    client = pymongo.MongoClient(mongo_uri)
    parsed_uri = pymongo.uri_parser.parse_uri(mongo_uri)

    db = client[parsed_uri['database']]
    db['courses'].drop()

def _typify(value, data_type):
    if data_type.startswith('varchar'):
        return value
    if data_type.startswith('int'):
        return int(value) if value else 0
    if data_type.startswith('time'):
        input_time = '%sM' % value # given data is in form '09:00A'
        # Converts to four digit 24 hour time 0000 - 2359
        return time.strftime('%H%M', time.strptime(input_time, '%I:%M%p'))
    else:
        print 'WARN: Unidentified type'
        return None

# Downcases the key for each pair
def downcase_pairs(pairs):
    new_pairs = []
    for pair in pairs:
        # Downcase first char of string
        pair_key = pair[0]
        if isinstance(pair_key, (str, unicode)):
            pair_key = pair_key[0].lower() + pair_key[1:]
        new_pairs.append((pair_key, pair[1]))
    return new_pairs

def get_section_info(doc):
    pairs = [(name, _typify(doc.get(name), data_type)) for (name,
            data_type) in section_schema if name not in special_fields]
    pairs += _special_treatment_section(doc)

    return dict(downcase_pairs(pairs))

# Will camelCase and process special fields
def get_course_info(doc):
    pairs = [(name, _typify(doc.get(name), data_type)) for (name,
            data_type) in course_schema if name not in special_fields]
    pairs += _special_treatment_course(doc)

    new_doc = dict(downcase_pairs(pairs))

    return new_doc

def load_data(args):
    client = pymongo.MongoClient(args.mongo_uri)
    parsed_uri = pymongo.uri_parser.parse_uri(args.mongo_uri)

    db = client[parsed_uri['database']]
    courses_db = db['courses']
    bulk = courses_db.initialize_unordered_bulk_op()

    dump_file = args.dump_file
    with open(dump_file) as f:
        docs = json.load(f)
    courses = map(get_course_info, docs)
    sections = map(get_section_info, docs)

    for course in courses:
        update_doc = {'$setOnInsert': course}
        bulk.find({'courseFull': course['courseFull']})\
            .upsert().update(update_doc)

    result = bulk.execute()
    # Remove giant list of objectIDs returned
    result.pop('upserted', None)
    print result
    print '%d courses in db.' % courses_db.count()


    sections_db = db['sections']
    bulk = sections_db.initialize_unordered_bulk_op()

    for section in sections:
        update_doc = {'$set': section}
        bulk.find({'sectionFull': section['sectionFull']})\
            .upsert().update(update_doc)

    try:
        result = bulk.execute()
    except pymongo.errors.BulkWriteError as bwe:
        print(bwe.details)
    # Remove giant list of objectIDs returned
    result.pop('upserted', None)
    print result
    print '%d sections in db.' % sections_db.count()


def main():
    parser = argparse.ArgumentParser(description="""Read a directory of courses
            JSON dump file and writes to Mongo.""")
    parser.add_argument('--drop', action='store_true', help="""drop the
            courses collection""")
    parser.add_argument('dump_file')
    parser.add_argument('mongo_uri', help="""URI of the mongo database including
        which database""")
    args = parser.parse_args()
    if args.drop:
        drop_table(args.mongo_uri)
    else:
        load_data(args)

if __name__ == "__main__":
    main()