class ExciseRouter:
    """
    Routes all vehicle-related models to excise_db
    """

    route_app_labels = {"vehicles"}

    def db_for_read(self, model, **hints):
        if model._meta.app_label in self.route_app_labels:
            return "excise_db"
        return None

    def db_for_write(self, model, **hints):
        if model._meta.app_label in self.route_app_labels:
            return "excise_db"
        return None

    def allow_relation(self, obj1, obj2, **hints):
        return True

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        if app_label in self.route_app_labels:
            return db == "excise_db"
        return db == "default"