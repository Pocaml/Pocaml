#include <stdint.h>
#include <string.h>

void *_make_int(int32_t n) {
    int32_t *p = malloc(sizeof(int32_t));
    *p = n;
    return (void *) p;
}

void *_make_bool(int8_t bool) {
    int8_t *p = malloc(sizeof(int8_t));
    *p = bool;
    return (void *) p;
}

void *_make_char(int8_t c) {
    int8_t *p = malloc(sizeof(int8_t));
    *p = c;
    return (void *) p;
}

void *_make_string(int8_t *s) {
    int8_t *p = malloc(strlen(s));
    strcpy(p, s);
    return (void *) p;
}

int8_t _unit = 69;

void *_make_unit() {
    return &_unit;
}

struct _pocaml_list {
    void *data;
    struct _pocaml_list *next;
};

void *_pocaml_end_list = NULL;

void *_make_list(void *data, void *next) {
    struct _pocaml_list *p = malloc(sizeof(struct _pocaml_list));
    p->data = data;
    p->next = (struct _pocaml_list *) next;
    return p;
}
